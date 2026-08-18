# Biogest Clinic - MyBio

A new Flutter project.

## Auto commit

The PowerShell launcher automatically uses the current Git branch:

```powershell
.\auto-commit.ps1
```

Add an optional commit message:

```powershell
.\auto-commit.ps1 "Commit message"
```

To pull from `test` after committing and before pushing:

```powershell
.\auto-commit.ps1 "Commit message" -PullFromTest
```

Without a message, the commit uses `Auto commit` followed by the current timestamp.

## Android auto-update

When the application starts, `AppUpdateService` checks the latest version
published on GitHub in the background:

```text
https://github.com/consultit-angola/BiogestClinic.Mobile/releases/latest
```

The check does not block startup and only runs on Android. The service follows
this flow:

1. Fetches the latest release through the GitHub API.
2. Reads its `tag_name` and finds the first attached file whose name ends in
   `.apk`.
3. Compares the tag with the installed version declared in `pubspec.yaml`.
4. If the release is newer, downloads the APK to the application's temporary
   directory.
5. Opens the Android package installer so the user can confirm the update.

For example, if the installed application has this version:

```yaml
version: 1.0.1+2
```

a release tagged `v1.0.2` is considered newer. The build number after `+` is not
used in the comparison.

### Publishing an update

Android production releases are built from the remote `main` branch and
published by GitHub Actions. From a clean repository, use the Git alias:

```powershell
# Production release from main
git release-android main
```

The alias calls the tracked PowerShell launcher internally. The equivalent
command, useful in a clone where the alias has not been configured, is:

```powershell
.\release.ps1 main
```

The command verifies that the branch exists on `origin` and dispatches the
`release-android.yml` workflow. The workflow reads the exact version and build
number from `pubspec.yaml`, runs analysis and tests, builds one signed APK for
each configured clinic, generates release notes from the changes since the
previous tag, and publishes the tag with all clinic APKs.

Configure these GitHub Actions secrets before the first release:

- `BIOGEST_ANDROID_KEYSTORE_BASE64`
- `BIOGEST_ANDROID_KEY_ALIAS`
- `BIOGEST_ANDROID_KEY_PASSWORD`
- `BIOGEST_ANDROID_STORE_PASSWORD`

#### Choosing the release version

Before dispatching the release, update `pubspec.yaml` using the
`MAJOR.MINOR.PATCH+BUILD` format. For example:

```yaml
version: 1.1.4+6
```

This produces version name `1.1.4`, Android build number `6`, tag `v1.1.4`,
release title `MyBio 1.1.4`, and APKs such as `MyBio-Zule-v1.1.4.apk`. Both the
semantic version and build number must be increased manually when Android
requires a newer release. The clinic list and public API base URL are defined
once in `config/clinics.json`. The workflow reads that array, each APK receives
its clinic through `--dart-define`, and it only downloads future updates
matching that clinic.

Do not publish a normal GitHub Release from `test` or a development branch.
The mobile application checks the latest published release globally, so clients
could receive a build that has not passed through `main`.

The workflow does not calculate, increment, or modify the version in the
selected source branch. It fails if the tag declared by `pubspec.yaml` already
exists.

Android requires the `REQUEST_INSTALL_PACKAGES` permission, which is already
declared in `android/app/src/main/AndroidManifest.xml`. Depending on the Android
version, the user may also need to allow MyBio to install applications from
unknown sources. The application never installs the APK without user
confirmation.

Network errors, missing APK assets, invalid responses, or installer cancellation
are ignored so they do not prevent the application from starting. The
application currently does not display a notification when the check fails, and
auto-update is not available for iOS, web, or desktop.

## Automated tests

The project uses `flutter_test`, which is included in the Flutter SDK. Flutter
should be run through FVM in this repository to keep the same SDK version used by
the team.

```powershell
# Run the complete test suite
.\.fvm\flutter_sdk\bin\flutter.bat test

# Run a specific test file
.\.fvm\flutter_sdk\bin\flutter.bat test test\controllers_test.dart

# Run a test by name
.\.fvm\flutter_sdk\bin\flutter.bat test --plain-name "maps permissions"

# Generate the coverage report
.\.fvm\flutter_sdk\bin\flutter.bat test --coverage
```

### Creating a test

1. Create a file inside `test/` that matches the subject of the production code
   and uses the `_test.dart` suffix.
2. Import the production file and `flutter_test/flutter_test.dart`.
3. Group related behavior with `group` and define each scenario with `test`.
4. Prepare small input data, perform one action, and verify the result with
   `expect`.

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Version comparison', () {
    test('detects a newer version', () {
      final result = AppUpdateService.isNewerVersion('1.1.0', '1.0.0');

      expect(result, isTrue);
    });
  });
}
```

For widgets, replace `test` with `testWidgets`, build the screen with
`tester.pumpWidget`, interact with it using `tester.tap` or `tester.enterText`,
and verify visible elements with `find.text`, `find.byType`, or `find.byKey`.
HTTP tests must not call the real server: inject a fake client or provider and
test successful responses, errors, and loading states separately.

Before delivering a change, also run:

```powershell
.\.fvm\flutter_sdk\bin\dart.bat format --output=none --set-exit-if-changed lib test
.\.fvm\flutter_sdk\bin\dart.bat analyze
.\.fvm\flutter_sdk\bin\flutter.bat test
```
