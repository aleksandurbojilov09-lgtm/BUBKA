import 'dart:io';

import 'package:flutter/services.dart';

import '../database/connection.dart';
import 'update_manifest.dart';
import 'update_transport.dart';

enum UpdateChannel { stable, testing }

class AvailableUpdate {
  const AvailableUpdate(this.asset, this.notes);
  final UpdateAsset asset;
  final String notes;
}

class UpdateService {
  UpdateService({
    required this.current,
    this.channel = UpdateChannel.stable,
    UpdateTransport? transport,
    Future<Directory> Function()? directory,
  }) : _transport = transport ?? UpdateTransport(),
       _directory = directory ?? localDataDirectory;

  final ReleaseVersion current;
  final UpdateChannel channel;
  final UpdateTransport _transport;
  final Future<Directory> Function() _directory;
  static const _native = MethodChannel('bubka/updates');
  AvailableUpdate? _available;

  Future<AvailableUpdate?> check({bool manual = false}) async {
    final root = await _directory();
    final marker = File('${root.path}/update-check-${channel.name}.txt');
    final now = DateTime.now();
    if (!manual && await marker.exists()) {
      final previous = DateTime.tryParse(await marker.readAsString());
      if (previous != null &&
          !now.isBefore(previous) &&
          now.difference(previous) < const Duration(hours: 24)) {
        return _available;
      }
    }
    await marker.writeAsString(now.toIso8601String(), flush: true);
    final platform = Platform.isAndroid ? 'android' : 'ios';
    final raw = await _transport.json(
      Uri.https('api.github.com', '/repos/$releaseRepository/releases', {
        'per_page': '20',
      }),
    ) as List<dynamic>;
    AvailableUpdate? best;
    for (final item in raw) {
      final release = item as Map<String, dynamic>;
      if (release['draft'] == true ||
          (channel == UpdateChannel.stable && release['prerelease'] == true)) {
        continue;
      }
      final tag = release['tag_name'] as String;
      if (!RegExp(r'^v[0-9]+\.[0-9]+\.[0-9]+$').hasMatch(tag)) {
        continue;
      }
      final assets = release['assets'] as List<dynamic>;
      if (!assets.any((entry) => entry['name'] == 'update-manifest.json')) {
        continue;
      }
      final manifest = await _transport.json(
        Uri.https(
          'github.com',
          '/$releaseRepository/releases/download/$tag/update-manifest.json',
        ),
      ) as Map<String, dynamic>;
      if (manifest['tag'] != tag ||
          manifest['channel'] !=
              (release['prerelease'] == true ? 'testing' : 'stable')) {
        throw const FormatException('Release manifest mismatch');
      }
      for (final entry in manifest['assets'] as List<dynamic>) {
        final asset = UpdateAsset.fromJson(entry as Map<String, dynamic>);
        if (asset.platform != platform ||
            'v${asset.version.version}' != tag ||
            !asset.version.isUpgradeFrom(current)) {
          continue;
        }
        if (!assets.any(
          (a) =>
              a['name'] == asset.filename &&
              a['size'] == asset.size &&
              Uri.parse(a['browser_download_url'] as String).pathSegments
                      .join('/') ==
                  asset.url.pathSegments.join('/'),
        )) {
          throw const FormatException('Missing published asset');
        }
        if (best == null || asset.version.isUpgradeFrom(best.asset.version)) {
          best = AvailableUpdate(
            asset,
            (release['body'] as String? ?? '').trim(),
          );
        }
      }
    }
    return _available = best;
  }

  Future<String> install(
    AvailableUpdate update,
    void Function(double) progress,
  ) async {
    final asset = update.asset;
    if (!asset.version.isUpgradeFrom(current)) {
      throw const FormatException('Not an upgrade');
    }
    final root = await _directory();
    final folder = Directory('${root.path}/updates');
    await folder.create(recursive: true);
    final file = File('${folder.path}/${asset.filename}');
    await _transport.get(asset.url, (response) async {
      await writeVerifiedAsset(
        stream: response,
        destination: file,
        expectedSize: asset.size,
        checksum: asset.sha256,
        progress: progress,
      );
    });
    try {
      return await _native.invokeMethod<String>('install', {
            'path': file.path,
            'build': asset.version.build,
            'version': asset.version.version.toString(),
          }) ??
          'opened';
    } catch (_) {
      if (await file.exists()) {
        await file.delete();
      }
      rethrow;
    }
  }
}
