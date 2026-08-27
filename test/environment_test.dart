import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loads the socket server secret from the environment asset', (
    tester,
  ) async {
    dotenv.clean();
    await dotenv.load(fileName: '.env');

    expect(dotenv.env['SOCKET_SERVER_SECRET']?.trim(), isNotEmpty);
  });
}
