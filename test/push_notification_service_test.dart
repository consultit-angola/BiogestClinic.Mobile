import 'package:biogest_clinic_mobile/app/data/services/push_notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(dotenv.clean);

  test('creates Firebase options when every environment value exists', () {
    dotenv.loadFromString(
      envString: '''
FIREBASE_API_KEY=api-key
FIREBASE_APP_ID=app-id
FIREBASE_MESSAGING_SENDER_ID=sender-id
FIREBASE_PROJECT_ID=project-id
''',
    );

    final options = FirebaseEnvironmentOptions.fromEnvironment();

    expect(options, isNotNull);
    expect(options!.apiKey, 'api-key');
    expect(options.appId, 'app-id');
    expect(options.messagingSenderId, 'sender-id');
    expect(options.projectId, 'project-id');
  });

  test(
    'does not create Firebase options when an environment value is missing',
    () {
      dotenv.loadFromString(
        envString: '''
FIREBASE_API_KEY=api-key
FIREBASE_APP_ID=app-id
FIREBASE_MESSAGING_SENDER_ID=sender-id
''',
      );

      expect(FirebaseEnvironmentOptions.fromEnvironment(), isNull);
    },
  );
}
