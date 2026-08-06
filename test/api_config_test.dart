import 'package:biogest_clinic_mobile/app/data/shared/api_config.dart';
import 'package:biogest_clinic_mobile/app/data/shared/preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Preferences().initPrefs();
    dotenv.loadFromString(
      envString: 'API_URL=https://example.test/Biogest.WebAPI.Zule/api',
    );
  });

  test('defaultApiUrl always targets Demo', () {
    expect(
      ApiConfig.defaultApiUrl,
      'https://example.test/Biogest.WebAPI.Demo/api',
    );
  });

  test('buildApiUrl normalizes known API names', () {
    expect(
      ApiConfig.buildApiUrl("  'bomsenso'  "),
      'https://example.test/Biogest.WebAPI.BomSenso/api',
    );
  });

  test('extractApiName reads and normalizes the tenant segment', () {
    expect(
      ApiConfig.extractApiName('https://example.test/Biogest.WebAPI.zule/api/'),
      'Zule',
    );
    expect(ApiConfig.extractApiName('https://example.test/api'), isEmpty);
  });

  test('setActiveApiName persists both name and URL', () async {
    await ApiConfig.setActiveApiName('testfe');

    expect(ApiConfig.activeApiName, 'TestFE');
    expect(
      ApiConfig.activeApiUrl,
      'https://example.test/Biogest.WebAPI.TestFE/api',
    );
  });

  test(
    'availableApiNames is sorted and contains the selected custom API',
    () async {
      await ApiConfig.setActiveApiName('ClinicSandbox');

      final names = ApiConfig.availableApiNames;
      expect(names, contains('ClinicSandbox'));
      expect(names, orderedEquals([...names]..sort()));
    },
  );
}
