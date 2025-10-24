import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../data/models/index.dart';
import '../data/providers/provider.dart';
import '../data/shared/index.dart';
import '../routes/index.dart';
import 'index.dart';

class LoginController extends GetxController {
  static LoginController get to => Get.find<LoginController>();
  final formKey = GlobalKey<FormBuilderState>();
  RxBool mostrarPass = false.obs;
  final Provider _provider = Provider();
  final Logger logger = Logger();

  final Preferences _pref = Preferences();
  final globalController = GlobalController.to;

  List<StoreDTO> stores = [];
  int? selectedStoreID;

  RxBool tryLogin = true.obs;

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

  void login({String? username, String? password}) async {
    if ((username == null || username == '') &&
        (password == null || password == '') &&
        formKey.currentState!.saveAndValidate()) {
      username = formKey.currentState!.fields['username']!.value;
      password = formKey.currentState!.fields['password']!.value;
      selectedStoreID = (formKey.currentState!.fields['store']!.value)?.id;
    }

    if (username != '' &&
        password != '' &&
        selectedStoreID != -1 &&
        selectedStoreID != null) {
      try {
        EasyLoading.show();
        Map<String, dynamic> resp = await _provider.login(
          username: username ?? '',
          password: password ?? '',
          storeID: selectedStoreID!,
        );
        if (resp['ok']) {
          globalController.authenticatedUser.value =
              (resp['data'] as AuthResponseDTO).userInfo;

          globalController.authenticatedEmployee.value =
              (resp['data'] as AuthResponseDTO).employee;

          logger.i('El usuario esta logeado');
          globalController.isAuthenticated.value = true;

          globalController.initControllers();

          EasyLoading.dismiss();
          Get.offAllNamed(Routes.home);
        } else {
          Get.snackbar('Error', resp['message']);
        }
        EasyLoading.dismiss();
        tryLogin.value = false;
      } catch (error) {
        EasyLoading.dismiss();
        Get.snackbar('Error', '$error');
        log('Error: $error');
        tryLogin.value = false;
      }
    }
  }

  Future<void> tryAutoLogin() async {
    if (_pref.username != '' && _pref.pass != '' && _pref.storeID != -1) {
      selectedStoreID = _pref.storeID;
      login(username: _pref.username, password: _pref.pass);
    } else {
      tryLogin.value = false;
    }
  }
}
