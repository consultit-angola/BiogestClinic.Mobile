import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../shared/api_config.dart';

class AppRelease {
  const AppRelease({
    required this.version,
    required this.currentVersion,
    required this.releaseNotes,
    required this.apkName,
    required this.downloadUri,
  });

  final String version;
  final String currentVersion;
  final String releaseNotes;
  final String apkName;
  final Uri downloadUri;
}

class AppUpdateService {
  static final Uri _latestReleaseUri = Uri.parse(
    'https://api.github.com/repos/consultit-angola/'
    'BiogestClinic.Mobile/releases/latest',
  );

  http.Client? _downloadClient;
  File? _partialFile;

  Future<AppRelease?> getAvailableUpdate() async {
    if (!Platform.isAndroid) return null;

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
    final packageInfo = await PackageInfo.fromPlatform();
    if (!isNewerVersion(tagName, packageInfo.version)) return null;

    final assets = data['assets'] as List<dynamic>? ?? const [];
    for (final item in assets) {
      final asset = item as Map<String, dynamic>;
      final name = asset['name']?.toString() ?? '';
      final downloadUrl = asset['browser_download_url']?.toString() ?? '';
      if (isClinicApk(name, ApiConfig.defaultApiName) &&
          downloadUrl.isNotEmpty) {
        return AppRelease(
          version: _cleanVersion(tagName),
          currentVersion: packageInfo.version,
          releaseNotes: formatReleaseNotes(data['body']?.toString() ?? ''),
          apkName: name,
          downloadUri: Uri.parse(downloadUrl),
        );
      }
    }

    return null;
  }

  Future<File> downloadApk(
    AppRelease release, {
    required void Function(double progress) onProgress,
  }) async {
    final directory = await getTemporaryDirectory();
    final safeName = release.apkName.replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]'),
      '_',
    );
    final file = File('${directory.path}${Platform.pathSeparator}$safeName');
    _partialFile = file;
    if (await file.exists()) await file.delete();

    final client = http.Client();
    _downloadClient = client;
    final request = http.Request('GET', release.downloadUri);
    final response = await client
        .send(request)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('APK download failed: ${response.statusCode}');
    }

    final totalBytes = response.contentLength ?? 0;
    var receivedBytes = 0;
    final sink = file.openWrite();
    try {
      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) onProgress(receivedBytes / totalBytes);
      }
      await sink.flush();
      await sink.close();
      onProgress(1);
      _partialFile = null;
      return file;
    } catch (_) {
      await sink.close();
      if (await file.exists()) await file.delete();
      rethrow;
    } finally {
      client.close();
      if (identical(_downloadClient, client)) _downloadClient = null;
    }
  }

  Future<void> cancelDownload() async {
    _downloadClient?.close();
    _downloadClient = null;
    final file = _partialFile;
    _partialFile = null;
    if (file != null && await file.exists()) await file.delete();
  }

  Future<void> installApk(File apkFile) async {
    await OpenFilex.open(
      apkFile.path,
      type: 'application/vnd.android.package-archive',
    );
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

  static bool isClinicApk(String assetName, String clinicCode) {
    final escapedClinic = RegExp.escape(clinicCode.trim());
    return RegExp(
      '^MyBio-$escapedClinic-v.+\\.apk\$',
      caseSensitive: false,
    ).hasMatch(assetName.trim());
  }

  static String formatReleaseNotes(String notes) {
    final formattedLines = <String>[];

    for (final originalLine in notes.split(RegExp(r'\r?\n'))) {
      var line = originalLine.trim();
      if (line.isEmpty) continue;
      if (line.toLowerCase().contains('full changelog')) continue;

      line = line.replaceFirst(RegExp(r'^#{1,6}\s*'), '');
      line = line.replaceAllMapped(
        RegExp(r'\*\*(.*?)\*\*'),
        (match) => match.group(1) ?? '',
      );
      line = line.replaceAllMapped(
        RegExp(r'__(.*?)__'),
        (match) => match.group(1) ?? '',
      );
      line = line.replaceAllMapped(
        RegExp(r'\[([^\]]+)\]\([^\)]+\)'),
        (match) => match.group(1) ?? '',
      );
      line = line.replaceFirst(RegExp(r'^[-*]\s+'), '• ');
      line = line.replaceAll(RegExp(r'\s+in\s+https?://\S+$'), '');

      if (line == 'What\'s Changed') continue;
      if (line.isNotEmpty) formattedLines.add(line);
    }

    return formattedLines.join('\n');
  }

  static String _cleanVersion(String version) {
    return version.trim().replaceFirst(RegExp(r'^[vV]'), '');
  }

  static List<int> _versionParts(String version) {
    final normalized = _cleanVersion(version);
    final core = normalized.split(RegExp(r'[-+]')).first;
    return core.split('.').map((part) => int.tryParse(part) ?? 0).toList();
  }
}
