import 'dart:io';

import 'package:get/get.dart';

import '../data/shared/preferences.dart';
import '../routes/app_routes.dart';
import '../services/app_update_service.dart';

enum AppUpdateStatus { checking, available, downloading, downloaded, error }

class AppUpdateController extends GetxController {
  AppUpdateController({AppUpdateService? service})
    : _service = service ?? AppUpdateService();

  final AppUpdateService _service;
  AppUpdateStatus status = AppUpdateStatus.checking;
  AppRelease? release;
  File? apkFile;
  double downloadProgress = 0;

  @override
  void onReady() {
    super.onReady();
    checkForUpdate();
  }

  Future<void> checkForUpdate() async {
    try {
      release = await _service.getAvailableUpdate();
      if (release == null) {
        _continueToApp();
        return;
      }
      status = AppUpdateStatus.available;
      update();
    } catch (_) {
      _continueToApp();
    }
  }

  Future<void> startDownload() async {
    final availableRelease = release;
    if (availableRelease == null) return;

    status = AppUpdateStatus.downloading;
    downloadProgress = 0;
    update();
    try {
      apkFile = await _service.downloadApk(
        availableRelease,
        onProgress: (progress) {
          downloadProgress = progress;
          update();
        },
      );
      status = AppUpdateStatus.downloaded;
    } catch (_) {
      status = AppUpdateStatus.error;
    }
    update();
  }

  Future<void> installUpdate() async {
    final file = apkFile;
    if (file != null) await _service.installApk(file);
  }

  Future<void> continueWithoutUpdating() async {
    if (status == AppUpdateStatus.downloading) {
      await _service.cancelDownload();
    }
    _continueToApp();
  }

  void _continueToApp() {
    final route = Preferences().skipSplash ? Routes.login : Routes.splash;
    Get.offAllNamed(route);
  }

  @override
  void onClose() {
    _service.cancelDownload();
    super.onClose();
  }
}
