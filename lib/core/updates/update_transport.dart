import 'dart:io';
import 'dart:convert';

import 'package:crypto/crypto.dart';

class UpdateTransport {
  static const _hosts = {
    'api.github.com',
    'github.com',
    'release-assets.githubusercontent.com',
    'objects.githubusercontent.com',
  };

  Future<T> get<T>(
    Uri uri,
    Future<T> Function(HttpClientResponse) consume,
  ) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 12);
    try {
      for (var redirects = 0; redirects <= 5; redirects++) {
        if (uri.scheme != 'https' ||
            !_hosts.contains(uri.host) ||
            uri.userInfo.isNotEmpty ||
            uri.port != 443) {
          throw const FormatException('Untrusted update host');
        }
        final request = await client
            .getUrl(uri)
            .timeout(const Duration(seconds: 15));
        request.followRedirects = false;
        request.headers.set('User-Agent', 'BUBKA');
        final response = await request.close().timeout(
          const Duration(seconds: 20),
        );
        if (const {301, 302, 303, 307, 308}.contains(response.statusCode)) {
          final location = response.headers.value('location');
          if (location == null) {
            throw const FormatException('Missing redirect');
          }
          uri = uri.resolve(location);
          await response.drain<void>().timeout(const Duration(seconds: 15));
          continue;
        }
        if (response.statusCode != 200) {
          throw HttpException('GitHub HTTP ${response.statusCode}');
        }
        return await consume(response).timeout(const Duration(minutes: 10));
      }
      throw const FormatException('Too many redirects');
    } finally {
      client.close(force: true);
    }
  }

  Future<dynamic> json(Uri uri) => get(uri, (response) async {
    final bytes = <int>[];
    await for (final chunk in response.timeout(const Duration(seconds: 20))) {
      bytes.addAll(chunk);
      if (bytes.length > 1024 * 1024) {
        throw const FormatException('Response too large');
      }
    }
    return jsonDecode(utf8.decode(bytes));
  });
}

Future<void> writeVerifiedAsset({
  required Stream<List<int>> stream,
  required File destination,
  required int expectedSize,
  required String checksum,
  required void Function(double) progress,
}) async {
  final stage = File('${destination.path}.part');
  final output = await stage.open(mode: FileMode.write);
  var size = 0;
  try {
    try {
      await for (final bytes in stream.timeout(const Duration(seconds: 30))) {
        size += bytes.length;
        if (size > expectedSize) {
          throw const FormatException('Unexpected download size');
        }
        await output.writeFrom(bytes);
        progress(size / expectedSize);
      }
      await output.flush();
    } finally {
      await output.close();
    }
    if (size != expectedSize ||
        (await sha256.bind(stage.openRead()).first).toString() != checksum) {
      throw const FormatException('Download checksum or size mismatch');
    }
    await stage.rename(destination.path);
  } finally {
    if (await stage.exists()) {
      await stage.delete();
    }
  }
}
