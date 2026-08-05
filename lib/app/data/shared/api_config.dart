import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'preferences.dart';

class ApiConfig {
  static const String defaultApiName = 'Demo';
  static const List<String> predefinedApiNames = [
    'Afrodente',
    'Ausmed',
    'Belodente',
    'BomSenso',
    'ClinicaMaster',
    'Demo',
    'DentalCenter',
    'FisioHealth',
    'FisioLuanda',
    'Freefarma',
    'Gav',
    'GolDente',
    'Healthtek',
    'HPLS',
    'Immunize',
    'Junic',
    'Magnus',
    'Makarismo',
    'OralClinic',
    'Publish',
    'Raizes',
    'SmileDente',
    'Test',
    'TestFE',
    'Vitrea',
    'Zule',
  ];
  static const String fallbackBaseUrl =
      'https://biogestclinic.consultit-angola.com/Biogest.WebAPI';

  static final Preferences _preferences = Preferences();

  static String get defaultApiUrl {
    final configuredUrl = _normalizeUrl(dotenv.env['API_URL'] ?? '');
    final pattern = RegExp(
      r'^(https?://.+?/Biogest\.WebAPI\.)([^/]+)(/api/?$)',
    );
    final match = pattern.firstMatch(configuredUrl);
    if (match != null) {
      return '${match.group(1)}$defaultApiName${match.group(3)}';
    }
    return '$fallbackBaseUrl.$defaultApiName/api';
  }

  static String get activeApiUrl {
    final storedUrl = _normalizeUrl(_preferences.apiUrl);
    if (storedUrl.isNotEmpty) {
      final pattern = RegExp(
        r'^(https?://.+?/Biogest\.WebAPI\.)([^/]+)(/api/?$)',
      );
      final match = pattern.firstMatch(storedUrl);
      if (match != null) {
        final storedApiName = _normalizeName(match.group(2) ?? '');
        return '${match.group(1)}$storedApiName${match.group(3)}';
      }
      return storedUrl;
    }
    return defaultApiUrl;
  }

  static String get activeApiName {
    final storedName = _normalizeName(_preferences.apiName);
    if (storedName.isNotEmpty) {
      return storedName;
    }
    return extractApiName(activeApiUrl);
  }

  static List<String> get availableApiNames {
    final names = <String>{...predefinedApiNames};

    names.add(defaultApiName);

    final selectedName = extractApiName(_preferences.apiUrl);
    if (selectedName.isNotEmpty) {
      names.add(selectedName);
    }

    final result = names.toList()..sort();
    return result;
  }

  static String buildApiUrl(String apiName) {
    final normalizedName = _normalizeName(apiName);
    if (normalizedName.isEmpty) {
      return defaultApiUrl;
    }

    final pattern = RegExp(
      r'^(https?://.+?/Biogest\.WebAPI\.)([^/]+)(/api/?$)',
    );
    final match = pattern.firstMatch(defaultApiUrl);
    if (match != null) {
      return '${match.group(1)}$normalizedName${match.group(3)}';
    }

    return '$fallbackBaseUrl.$normalizedName/api';
  }

  static String extractApiName(String apiUrl) {
    final normalizedUrl = _normalizeUrl(apiUrl);
    final pattern = RegExp(r'Biogest\.WebAPI\.([^/]+)/api/?$');
    final match = pattern.firstMatch(normalizedUrl);
    if (match == null) {
      return '';
    }
    return _normalizeName(match.group(1) ?? '');
  }

  static Future<void> setActiveApiName(String apiName) async {
    final normalizedName = _normalizeName(apiName);
    final selectedUrl = buildApiUrl(normalizedName);
    _preferences.apiName = normalizedName;
    _preferences.apiUrl = selectedUrl;
  }

  static String _normalizeUrl(String value) {
    return value.trim().replaceAll("'", '');
  }

  static String _normalizeName(String value) {
    final normalized = value.trim().replaceAll("'", '');
    if (normalized.isEmpty) {
      return '';
    }

    for (final apiName in predefinedApiNames) {
      if (apiName.toLowerCase() == normalized.toLowerCase()) {
        return apiName;
      }
    }

    return normalized;
  }
}
