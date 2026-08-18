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
}
