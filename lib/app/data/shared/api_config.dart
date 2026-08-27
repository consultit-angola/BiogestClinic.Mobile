import 'dart:convert';

import 'package:flutter/services.dart';

import 'preferences.dart';

class ApiConfig {
  static const String socketServerUrl =
      'https://biogestclinic.consultit-angola.com';

  static const String defaultApiName = String.fromEnvironment(
    'CLINIC_CODE',
    defaultValue: 'Demo',
  );

  static final Preferences _preferences = Preferences();
  static String _fallbackBaseUrl = '';
  static List<String> _predefinedApiNames = const [];

  static String get fallbackBaseUrl => _fallbackBaseUrl;

  static List<String> get predefinedApiNames => _predefinedApiNames;

  static Future<void> initialize({String? configJson}) async {
    final source =
        configJson ?? await rootBundle.loadString('config/clinics.json');
    final config = jsonDecode(source) as Map<String, dynamic>;
    final baseUrl = config['apiBaseUrl']?.toString().trim() ?? '';
    final clinics = (config['clinics'] as List<dynamic>? ?? const [])
        .map((clinic) => clinic.toString().trim())
        .where((clinic) => clinic.isNotEmpty)
        .toSet()
        .toList(growable: false);

    if (baseUrl.isEmpty || clinics.isEmpty) {
      throw const FormatException('Invalid clinic configuration.');
    }
    if (!clinics.any(
      (clinic) => clinic.toLowerCase() == defaultApiName.toLowerCase(),
    )) {
      throw FormatException(
        'Compiled clinic $defaultApiName is not configured.',
      );
    }

    _fallbackBaseUrl = baseUrl;
    _predefinedApiNames = clinics;
  }

  static String get defaultApiUrl =>
      '$fallbackBaseUrl.${_normalizeName(defaultApiName)}/api';

  static String get activeApiUrl {
    final storedUrl = _normalizeUrl(_preferences.apiUrl);
    return storedUrl.isNotEmpty ? storedUrl : defaultApiUrl;
  }

  static String get activeApiName {
    final storedName = _normalizeName(_preferences.apiName);
    return storedName.isNotEmpty ? storedName : defaultApiName;
  }

  static String get socketProjectKey {
    final apiName = activeApiName;
    const projectKeys = {
      'demo': 'demo',
      'goldente': 'prod-goldente',
      'hpls': 'prod-hpls-angola',
      'test': 'test',
      'testfe': 'test-fe',
      'zule': 'test2',
    };
    final knownKey = projectKeys[apiName.toLowerCase()];
    if (knownKey != null) return knownKey;

    final kebabCaseName = apiName
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match.group(1)}-${match.group(2)}',
        )
        .toLowerCase();
    return 'prod-$kebabCaseName';
  }

  static List<String> get availableApiNames {
    final names = <String>{...predefinedApiNames, defaultApiName};
    final selectedName = extractApiName(_preferences.apiUrl);
    if (selectedName.isNotEmpty) names.add(selectedName);
    return names.toList()..sort();
  }

  static String buildApiUrl(String apiName) {
    final normalizedName = _normalizeName(apiName);
    return '$fallbackBaseUrl.'
        '${normalizedName.isEmpty ? defaultApiName : normalizedName}/api';
  }

  static String extractApiName(String apiUrl) {
    final normalizedUrl = _normalizeUrl(apiUrl);
    final pattern = RegExp(r'Biogest\.WebAPI\.([^/]+)/api/?$');
    final match = pattern.firstMatch(normalizedUrl);
    return match == null ? '' : _normalizeName(match.group(1) ?? '');
  }

  static Future<void> setActiveApiName(String apiName) async {
    final normalizedName = _normalizeName(apiName);
    _preferences.apiName = normalizedName;
    _preferences.apiUrl = buildApiUrl(normalizedName);
  }

  static String _normalizeUrl(String value) {
    return value.trim().replaceAll("'", '');
  }

  static String _normalizeName(String value) {
    final normalized = value.trim().replaceAll("'", '');
    if (normalized.isEmpty) return '';

    for (final apiName in predefinedApiNames) {
      if (apiName.toLowerCase() == normalized.toLowerCase()) return apiName;
    }
    return normalized;
  }
}
