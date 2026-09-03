import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../data/models/index.dart';
import '../data/providers/provider.dart';
import '../ui/utils/app_toast.dart';
import 'global_controller.dart';

enum ClinicalRecordType { odontology, specialties }

class ClinicalRecordController extends GetxController {
  final Provider _provider = Provider();
  final client = Rxn<ClientDTO>();
  final recordType = ClinicalRecordType.specialties.obs;
  final appointments = <AppointmentDTO>[].obs;
  final selectedAppointment = Rxn<AppointmentDTO>();
  final appointmentServices = <AppointmentServiceDTO>[].obs;
  final digitalDocuments = <DigitalDocumentDTO>[].obs;
  final medicalDocuments = <ClientMedicalDocumentDTO>[].obs;
  final isLoadingClient = false.obs;
  final isLoadingHistory = false.obs;
  final isLoadingServices = false.obs;
  final isLoadingDigitalDocuments = false.obs;
  final isLoadingMedicalDocuments = false.obs;

  int get clientID => client.value?.id ?? 0;
  bool get isOdontology => recordType.value == ClinicalRecordType.odontology;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      final argClient = args['client'];
      if (argClient is ClientDTO) client.value = argClient;
      final argType = args['type'];
      if (argType is ClinicalRecordType) recordType.value = argType;
    }
    final parameterID = int.tryParse(Get.parameters['id'] ?? '');
    if (client.value == null && parameterID != null) {
      loadClient(parameterID);
    } else {
      loadResources();
    }
  }

  Future<void> loadClient(int id) async {
    isLoadingClient.value = true;
    final response = await _provider.getClientById(id);
    isLoadingClient.value = false;

    if (await GlobalController.to.handleResponseError(response)) return;
    if (response['ok'] != true) {
      AppToast.show('Erro', 'Não foi possível carregar o cliente.');
      return;
    }

    client.value = response['data'] as ClientDTO;
    loadResources();
  }

  Future<void> loadResources() async {
    if (clientID <= 0) return;
    await Future.wait([
      loadHistory(),
      loadDigitalDocuments(),
      loadMedicalDocuments(),
    ]);
  }

  Future<void> loadHistory() async {
    if (clientID <= 0) return;
    isLoadingHistory.value = true;
    final response = await _provider.getAppts({
      'ClientIDList': [clientID],
      'OnlyNotCanceled': true,
      'OrderByDesc': true,
    });
    isLoadingHistory.value = false;

    if (await GlobalController.to.handleResponseError(response)) return;
    if (response['ok'] != true) {
      AppToast.show('Erro', 'Não foi possível carregar o histórico.');
      return;
    }

    final loadedAppointments = response['data'] as List<AppointmentDTO>;
    appointments.assignAll(
      isOdontology
          ? loadedAppointments.where(_isOdontologyAppointment)
          : loadedAppointments,
    );
    selectedAppointment.value = null;
    appointmentServices.clear();
  }

  Future<void> loadServices(AppointmentDTO appointment) async {
    selectedAppointment.value = appointment;
    isLoadingServices.value = true;
    final response = await _provider.getAppointmentServices(appointment.id);
    isLoadingServices.value = false;

    if (await GlobalController.to.handleResponseError(response)) return;
    if (response['ok'] != true) {
      AppToast.show('Erro', 'Não foi possível carregar os serviços.');
      return;
    }
    appointmentServices.assignAll(
      response['data'] as List<AppointmentServiceDTO>,
    );
  }

  Future<void> loadDigitalDocuments() async {
    if (clientID <= 0) return;
    isLoadingDigitalDocuments.value = true;
    final response = await _provider.getClientDigitalDocuments(clientID);
    isLoadingDigitalDocuments.value = false;

    if (await GlobalController.to.handleResponseError(response)) return;
    if (response['ok'] != true) {
      AppToast.show('Erro', 'Não foi possível carregar documentos/imagens.');
      return;
    }
    final loadedDocuments = response['data'] as List<DigitalDocumentDTO>;
    loadedDocuments.sort((left, right) {
      final leftCreationTime = left.creationDate?.millisecondsSinceEpoch ?? 0;
      final rightCreationTime = right.creationDate?.millisecondsSinceEpoch ?? 0;
      final creationComparison = rightCreationTime.compareTo(leftCreationTime);
      if (creationComparison != 0) return creationComparison;
      return right.id.compareTo(left.id);
    });
    digitalDocuments.assignAll(loadedDocuments);
  }

  Future<void> loadMedicalDocuments() async {
    if (clientID <= 0) return;
    isLoadingMedicalDocuments.value = true;
    final response = await _provider.getClientMedicalDocuments(clientID);
    isLoadingMedicalDocuments.value = false;

    if (await GlobalController.to.handleResponseError(response)) return;
    if (response['ok'] != true) {
      AppToast.show('Erro', 'Não foi possível carregar documentos médicos.');
      return;
    }
    final loadedDocuments = response['data'] as List<ClientMedicalDocumentDTO>;
    loadedDocuments.sort((left, right) {
      final leftCreationTime = left.creationDate?.millisecondsSinceEpoch ?? 0;
      final rightCreationTime = right.creationDate?.millisecondsSinceEpoch ?? 0;
      final creationComparison = rightCreationTime.compareTo(leftCreationTime);
      if (creationComparison != 0) return creationComparison;
      return right.id.compareTo(left.id);
    });
    medicalDocuments.assignAll(loadedDocuments);
  }

  bool _isOdontologyAppointment(AppointmentDTO appointment) {
    final specialty = appointment.medicalSpecialty?.name.toLowerCase() ?? '';
    return specialty.contains('dent') ||
        specialty.contains('odont') ||
        specialty.contains('orto') ||
        specialty.contains('endo') ||
        specialty.contains('period') ||
        specialty.contains('impl');
  }

  Future<void> openDigitalDocument(DigitalDocumentDTO document) async {
    if (document.data.isEmpty) {
      AppToast.show('Erro', 'Este documento não tem conteúdo para abrir.');
      return;
    }

    try {
      final bytes = base64Decode(_cleanBase64(document.data));
      final tempDirectory = await getTemporaryDirectory();
      final fileName = _resolveFileName(document, bytes);
      final file = File(
        '${tempDirectory.path}${Platform.pathSeparator}$fileName',
      );
      await file.writeAsBytes(bytes, flush: true);

      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        AppToast.show('Erro', result.message);
      }
    } catch (error) {
      AppToast.show('Erro', 'Não foi possível abrir o documento: $error');
    }
  }

  String _cleanBase64(String data) {
    final commaIndex = data.indexOf(',');
    if (data.startsWith('data:') && commaIndex >= 0) {
      return data.substring(commaIndex + 1).replaceAll(RegExp(r'\s+'), '');
    }
    return data.replaceAll(RegExp(r'\s+'), '');
  }

  String _resolveFileName(DigitalDocumentDTO document, List<int> bytes) {
    final safeName = (document.name.isNotEmpty ? document.name : 'documento')
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    if (safeName.contains('.')) {
      return safeName;
    }
    return '$safeName${_resolveFileExtension(document, bytes)}';
  }

  String _resolveFileExtension(DigitalDocumentDTO document, List<int> bytes) {
    if (_isPdf(bytes)) return '.pdf';
    if (_isPng(bytes)) return '.png';
    if (_isJpeg(bytes)) return '.jpg';
    if (document.dataTypeID == 2) return '.pdf';
    return '.bin';
  }

  bool _isPdf(List<int> bytes) {
    return bytes.length >= 5 &&
        bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46 &&
        bytes[4] == 0x2d;
  }

  bool _isPng(List<int> bytes) {
    return bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4e &&
        bytes[3] == 0x47;
  }

  bool _isJpeg(List<int> bytes) {
    return bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff;
  }
}
