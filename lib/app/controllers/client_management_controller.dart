import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models/index.dart';
import '../data/providers/provider.dart';
import '../routes/index.dart';
import '../ui/utils/app_toast.dart';
import 'clinical_record_controller.dart';
import 'global_controller.dart';

class ClientManagementController extends GetxController {
  final Provider _provider = Provider();
  final searchController = TextEditingController();
  final clients = <ClientDTO>[].obs;
  final isLoading = false.obs;
  final hasSearched = false.obs;

  Future<void> searchClients() async {
    final query = searchController.text.trim();
    if (query.isEmpty) {
      clients.clear();
      hasSearched.value = false;
      return;
    }

    isLoading.value = true;
    hasSearched.value = true;
    final response = await _provider.searchClientList(name: query);
    isLoading.value = false;

    if (await GlobalController.to.handleResponseError(response)) return;
    if (response['ok'] != true) {
      AppToast.show('Erro', 'Não foi possível pesquisar clientes.');
      return;
    }

    clients.assignAll(response['data'] as List<ClientDTO>);
  }

  void showActionUnavailable(String action) {
    AppToast.show('Informação', '$action ainda não está disponível no mobile.');
  }

  Future<void> openClinicalRecord(
    ClientDTO client,
    ClinicalRecordType type,
  ) async {
    await Get.toNamed(
      Routes.clinicalRecord.replaceFirst(':id', '${client.id}'),
      arguments: {'client': client, 'type': type},
    );
  }

  Future<void> contactViaWhatsApp(ClientDTO client) async {
    final phoneNumber = client.phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (phoneNumber.isEmpty) {
      AppToast.show('Informação', 'Este cliente não tem telefone.');
      return;
    }

    final whatsappUri = Uri.parse('whatsapp://send?phone=$phoneNumber');
    final webUri = Uri.parse('https://wa.me/$phoneNumber');

    try {
      final launched = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (launched) return;

      final launchedWeb = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
      if (launchedWeb) return;
    } on PlatformException {
      AppToast.show('Erro', 'Não foi possível abrir o WhatsApp.');
      return;
    }

    AppToast.show('Erro', 'Não foi possível abrir o WhatsApp.');
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
