import 'package:biogest_clinic_mobile/app/services/app_update_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppUpdateService.isNewerVersion', () {
    test('accepts a newer release tag', () {
      expect(AppUpdateService.isNewerVersion('v1.1.0', '1.0.9'), isTrue);
    });

    test('rejects the installed version', () {
      expect(AppUpdateService.isNewerVersion('v1.0.0', '1.0.0'), isFalse);
    });

    test('rejects an older release', () {
      expect(AppUpdateService.isNewerVersion('v1.9.9', '2.0.0'), isFalse);
    });

    test('supports build metadata in the installed version', () {
      expect(AppUpdateService.isNewerVersion('v1.0.1', '1.0.0+12'), isTrue);
    });
  });
}
