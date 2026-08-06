import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class AppUpdateService {
  static final Uri _latestReleaseUri = Uri.parse(
    'https://api.github.com/repos/consultit-angola/'
    'BiogestClinic.Mobile/releases/latest',
  );

  Future<void> checkForUpdate() async {
    if (!Platform.isAndroid) return;

    try {
      final release = await _getLatestRelease();
      if (release == null) return;

      final packageInfo = await PackageInfo.fromPlatform();
      if (!isNewerVersion(release.version, packageInfo.version)) return;

      final apkFile = await _downloadApk(release);
      await OpenFilex.open(
        apkFile.path,
        type: 'application/vnd.android.package-archive',
      );
    } catch (_) {
      // An update failure must never interrupt the application startup.
    }
  }

  Future<_Release?> _getLatestRelease() async {
    final response = await http
        .get(
          _latestReleaseUri,
          headers: const {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
          },
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != HttpStatus.ok) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final tagName = data['tag_name']?.toString() ?? '';
    final assets = data['assets'] as List<dynamic>? ?? const [];

    for (final item in assets) {
      final asset = item as Map<String, dynamic>;
      final name = asset['name']?.toString() ?? '';
      final downloadUrl = asset['browser_download_url']?.toString() ?? '';
      if (name.toLowerCase().endsWith('.apk') && downloadUrl.isNotEmpty) {
        return _Release(
          version: tagName,
          apkName: name,
          downloadUri: Uri.parse(downloadUrl),
        );
      }
    }

    return null;
  }

  Future<File> _downloadApk(_Release release) async {
    final directory = await getTemporaryDirectory();
    final safeName = release.apkName.replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]'),
      '_',
    );
    final file = File('${directory.path}${Platform.pathSeparator}$safeName');

    final request = http.Request('GET', release.downloadUri);
    final response = await request.send().timeout(const Duration(seconds: 10));
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('APK download failed: ${response.statusCode}');
    }

    final sink = file.openWrite();
    try {
      await response.stream.pipe(sink);
    } catch (_) {
      await sink.close();
      if (await file.exists()) await file.delete();
      rethrow;
    }

    return file;
  }

  static bool isNewerVersion(String candidate, String current) {
    final candidateParts = _versionParts(candidate);
    final currentParts = _versionParts(current);
    final length = candidateParts.length > currentParts.length
        ? candidateParts.length
        : currentParts.length;

    for (var index = 0; index < length; index++) {
      final candidatePart = index < candidateParts.length
          ? candidateParts[index]
          : 0;
      final currentPart = index < currentParts.length ? currentParts[index] : 0;
      if (candidatePart != currentPart) return candidatePart > currentPart;
    }

    return false;
  }

  static List<int> _versionParts(String version) {
    final normalized = version.trim().replaceFirst(RegExp(r'^[vV]'), '');
    final core = normalized.split(RegExp(r'[-+]')).first;
    return core.split('.').map((part) => int.tryParse(part) ?? 0).toList();
  }
}

class _Release {
  const _Release({
    required this.version,
    required this.apkName,
    required this.downloadUri,
  });

  final String version;
  final String apkName;
  final Uri downloadUri;
}
