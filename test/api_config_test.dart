import 'package:biogest_clinic_mobile/app/data/shared/api_config.dart';
import 'package:biogest_clinic_mobile/app/data/shared/preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const configJson = '''
  {
    "apiBaseUrl": "https://example.test/Biogest.WebAPI",
    "clinics": ["Demo", "BomSenso", "TestFE", "Zule"]
  }
  ''';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Preferences().initPrefs();
    await ApiConfig.initialize(configJson: configJson);
  });

  test('uses the compiled clinic as the default API', () {
    expect(ApiConfig.defaultApiName, 'Demo');
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

  test('setActiveApiName persists the administrator override', () async {
    await ApiConfig.setActiveApiName('testfe');

    expect(ApiConfig.activeApiName, 'TestFE');
    expect(
      ApiConfig.activeApiUrl,
      'https://example.test/Biogest.WebAPI.TestFE/api',
    );
  });

  test('maps API names to the Angular socket project keys', () async {
    expect(ApiConfig.socketProjectKey, 'demo');

    await ApiConfig.setActiveApiName('BomSenso');
    expect(ApiConfig.socketProjectKey, 'prod-bom-senso');

    await ApiConfig.setActiveApiName('GolDente');
    expect(ApiConfig.socketProjectKey, 'prod-goldente');

    await ApiConfig.setActiveApiName('TestFE');
    expect(ApiConfig.socketProjectKey, 'test-fe');

    await ApiConfig.setActiveApiName('Zule');
    expect(ApiConfig.socketProjectKey, 'test2');
  });
}
