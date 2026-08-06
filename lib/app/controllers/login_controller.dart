import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../data/models/index.dart';
import '../data/providers/provider.dart';
import '../data/shared/index.dart';
import '../routes/index.dart';
import 'index.dart';

class LoginController extends GetxController {
  static LoginController get to => Get.find<LoginController>();
  final formKey = GlobalKey<FormBuilderState>();
  RxBool mostrarPass = false.obs;
  RxBool rememberSession = true.obs;
  RxString appVersion = ''.obs;
  final Provider _provider = Provider();

  final Preferences _pref = Preferences();
  final globalController = GlobalController.to;

  List<StoreDTO> stores = [];
  int? selectedStoreID;
  String selectedStoreName = '';

  RxBool tryLogin = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = packageInfo.version;
    } catch (_) {
      appVersion.value = '';
    }
  }

  Future<List<StoreDTO>> getStore() async {
    EasyLoading.show();
    Map<String, dynamic> resp = await _provider.getStores();
    if (resp['ok']) {
      EasyLoading.dismiss();
      return resp['data'] as List<StoreDTO>;
    } else {
      EasyLoading.dismiss();
      Get.snackbar('Error', resp['message']);
      return [];
    }
  }

  Future<void> login({String? username, String? password}) async {
    if ((username == null || username == '') &&
        (password == null || password == '') &&
        formKey.currentState!.saveAndValidate()) {
      username = formKey.currentState!.fields['username']!.value;
      password = formKey.currentState!.fields['password']!.value;
      selectedStoreID = (formKey.currentState!.fields['store']!.value)?.id;
      selectedStoreName =
          (formKey.currentState!.fields['store']!.value as StoreDTO?)?.name ??
          '';
    }

    if (username != '' &&
        password != '' &&
        selectedStoreID != -1 &&
        selectedStoreID != null) {
      try {
        EasyLoading.show(status: 'A iniciar sessão...');
        var resp = await _provider.login(
          username: username ?? '',
          password: password ?? '',
          storeID: selectedStoreID!,
        );

        if (resp['requiresForceLogout'] == true) {
          EasyLoading.dismiss();
          final shouldForceLogout = await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Sessões ativas'),
              content: Text(resp['message']?.toString() ?? ''),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Não'),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  child: const Text('Sim, encerrar'),
                ),
              ],
            ),
            barrierDismissible: false,
          );

          if (shouldForceLogout != true) {
            return;
          }

          EasyLoading.show(status: 'A iniciar sessão...');
          resp = await _provider.login(
            username: username ?? '',
            password: password ?? '',
            storeID: selectedStoreID!,
            forceLogout: true,
          );
        }

        if (resp['ok']) {
          if (!rememberSession.value) {
            _pref.username = '';
            _pref.pass = '';
            _pref.storeID = -1;
            _pref.storeName = '';
          } else {
            _pref.storeName = selectedStoreName;
          }
          final authResponse = resp['data'] as AuthResponseDTO;
          globalController.authenticatedUser.value = authResponse.userInfo;

          globalController.authenticatedEmployee.value = authResponse.employee;
          globalController.selectedStoreName.value = selectedStoreName;
          globalController.activePermissions.assignAll(
            authResponse.activePermissions,
          );
          globalController.markSessionActive();

          await globalController.initControllers();

          globalController.isAuthenticated.value = true;

          EasyLoading.dismiss();
          Get.offAllNamed(Routes.home);
        } else {
          Get.snackbar('Error', resp['message']);
        }
      } catch (error) {
        await globalController.clearSession();
        Get.snackbar('Error', '$error');
        log('Error: $error');
      } finally {
        EasyLoading.dismiss();
        tryLogin.value = false;
      }
    }
  }

  Future<void> tryAutoLogin() async {
    if (_pref.username != '' && _pref.pass != '' && _pref.storeID != -1) {
      selectedStoreID = _pref.storeID;
      selectedStoreName = _pref.storeName;
      login(username: _pref.username, password: _pref.pass);
    } else {
      tryLogin.value = false;
    }
  }
}
