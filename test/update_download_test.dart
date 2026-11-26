import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/updates/update_transport.dart';

void main() {
  test('verified download and failed replacement preserve original', () async {
    final folder = await Directory.systemTemp.createTemp('bubka-update-');
    addTearDown(() => folder.delete(recursive: true));
    final file = File('${folder.path}/app.apk');
    final bytes = [1, 2, 3];
    final checksum = sha256.convert(bytes).toString();
    await writeVerifiedAsset(
      stream: Stream.value(bytes),
      destination: file,
      expectedSize: 3,
      checksum: checksum,
      progress: (_) {},
    );
    expect(await file.readAsBytes(), bytes);
    await expectLater(
      writeVerifiedAsset(
        stream: Stream.value([4, 5, 6]),
        destination: file,
        expectedSize: 3,
        checksum: checksum,
        progress: (_) {},
      ),
      throwsFormatException,
    );
    expect(await file.readAsBytes(), bytes);
    expect(await File('${file.path}.part').exists(), isFalse);
  });
}
