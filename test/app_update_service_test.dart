import 'package:biogest_clinic_mobile/app/data/services/app_update_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppUpdateService.isClinicApk', () {
    test('accepts only the APK for the compiled clinic', () {
      expect(
        AppUpdateService.isClinicApk('MyBio-Zule-v1.2.0.apk', 'Zule'),
        isTrue,
      );
      expect(
        AppUpdateService.isClinicApk('MyBio-HPLS-v1.2.0.apk', 'Zule'),
        isFalse,
      );
      expect(AppUpdateService.isClinicApk('MyBio-v1.2.0.apk', 'Zule'), isFalse);
    });
  });

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

  group('AppUpdateService.formatReleaseNotes', () {
    test('removes a standalone full changelog link', () {
      const notes =
          '**Full Changelog**: https://github.com/example/app/compare/v1...v2';

      expect(AppUpdateService.formatReleaseNotes(notes), isEmpty);
    });

    test('formats GitHub markdown as readable text', () {
      const notes = '''
## What's Changed
* **New update screen** by @developer in https://github.com/example/pull/1
* Show the [installed version](https://github.com/example/pull/2)

**Full Changelog**: https://github.com/example/compare/v1...v2
''';

      expect(
        AppUpdateService.formatReleaseNotes(notes),
        '• New update screen by @developer\n'
        '• Show the installed version',
      );
    });
  });
}
