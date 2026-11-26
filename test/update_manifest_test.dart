import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/updates/update_manifest.dart';

void main() {
  test('numeric SemVer and monotonic build numbers', () {
    expect(ReleaseVersion('0.10.0', 8).isUpgradeFrom(ReleaseVersion('0.9.0', 7)), isTrue);
    expect(ReleaseVersion('0.1.0', 9).isUpgradeFrom(ReleaseVersion('0.2.0', 8)), isFalse);
    expect(ReleaseVersion('0.2.1', 8).isUpgradeFrom(ReleaseVersion('0.2.0', 8)), isFalse);
    expect(ReleaseVersion('0.2.0', 9).isUpgradeFrom(ReleaseVersion('0.2.0', 8)), isTrue);
  });

  test('manifest restricts asset to the approved repository and tag', () {
    final json = <String, dynamic>{
      'platform': 'android',
      'version': '0.2.1',
      'build_number': 4,
      'filename': 'BUBKA-0.2.1+4.apk',
      'download_url': 'https://github.com/$releaseRepository/releases/download/v0.2.1/BUBKA-0.2.1+4.apk',
      'sha256': List.filled(64, 'a').join(),
      'size_bytes': 100,
    };
    expect(UpdateAsset.fromJson(json).version.build, 4);
    json['download_url'] = 'https://example.org/app.apk';
    expect(() => UpdateAsset.fromJson(json), throwsFormatException);
  });
}
