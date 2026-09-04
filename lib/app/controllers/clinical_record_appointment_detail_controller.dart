import 'package:get/get.dart';

import '../data/models/index.dart';
import '../data/providers/provider.dart';
import '../ui/utils/app_toast.dart';
import 'global_controller.dart';

class ClinicalRecordAppointmentDetailController extends GetxController {
  final Provider _provider = Provider();

  final appointment = Rxn<AppointmentDTO>();
  final services = <AppointmentServiceDTO>[].obs;
  final isLoadingServices = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['appointment'] is AppointmentDTO) {
      appointment.value = args['appointment'] as AppointmentDTO;
      loadServices();
    }
  }

  Future<void> loadServices() async {
    final appointmentID = appointment.value?.id ?? 0;
    if (appointmentID <= 0) return;

    isLoadingServices.value = true;
    final response = await _provider.getAppointmentServices(appointmentID);
    isLoadingServices.value = false;

    if (await GlobalController.to.handleResponseError(response)) return;
    if (response['ok'] != true) {
      AppToast.show('Erro', 'Não foi possível carregar os serviços.');
      return;
    }

    services.assignAll(response['data'] as List<AppointmentServiceDTO>);
  }
}
