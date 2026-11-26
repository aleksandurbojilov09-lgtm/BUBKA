import 'package:pub_semver/pub_semver.dart';

const releaseRepository = 'aleksandurbojilov09-lgtm/BUBKA';

class ReleaseVersion {
  ReleaseVersion(String version, this.build) : version = Version.parse(version) {
    if (build < 1 || this.version.build.isNotEmpty) {
      throw const FormatException('Invalid release version/build');
    }
  }

  final Version version;
  final int build;

  bool isUpgradeFrom(ReleaseVersion current) =>
      build > current.build && version.compareTo(current.version) >= 0;
}

class UpdateAsset {
  UpdateAsset.fromJson(Map<String, dynamic> json)
    : platform = json['platform'] as String,
      version = ReleaseVersion(json['version'] as String, json['build_number'] as int),
      filename = json['filename'] as String,
      url = Uri.parse(json['download_url'] as String),
      sha256 = json['sha256'] as String,
      size = json['size_bytes'] as int {
    final suffix = switch (platform) {
      'android' => '.apk',
      'ios' => '.ipa',
      _ => throw const FormatException('Unknown platform'),
    };
    final expected = Uri.https(
      'github.com',
      '/$releaseRepository/releases/download/v${version.version}/$filename',
    );
    if (version.version.isPreRelease ||
        !RegExp(r'^[A-Za-z0-9.+_-]+$').hasMatch(filename) ||
        !filename.endsWith(suffix) ||
        url != expected ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(sha256) ||
        size < 1 ||
        size > 512 * 1024 * 1024) {
      throw const FormatException('Invalid update asset');
    }
  }

  final String platform;
  final ReleaseVersion version;
  final String filename;
  final Uri url;
  final String sha256;
  final int size;
}
