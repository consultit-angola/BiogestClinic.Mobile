import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/index.dart';
import '../../../data/models/index.dart';
import '../../index.dart';

class ClinicalRecordPage extends GetView<ClinicalRecordController> {
  const ClinicalRecordPage({super.key});

  static const int _clinicalRecordTabCount = 3;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _clinicalRecordTabCount,
      child: Scaffold(
        backgroundColor: CustomColors.backgroundColor,
        body: Column(
          children: [
            customAppbar(),
            _header(),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: _buildClinicalRecordTabs(),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Obx(_historyTab),
                  Obx(_digitalDocumentsTab),
                  Obx(_medicalDocumentsTab),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalRecordTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CustomColors.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CustomColors.borderColor),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              CustomColors.primaryDarkerColor,
              CustomColors.secondaryColor,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: CustomColors.primaryDarkerColor,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        tabs: const [
          Tab(icon: Icon(Icons.history_outlined, size: 18), text: 'Histórico'),
          Tab(
            icon: Icon(Icons.image_outlined, size: 18),
            child: Text('Documentos /\nImagens', textAlign: TextAlign.center),
          ),
          Tab(
            icon: Icon(Icons.description_outlined, size: 18),
            child: Text('Documentos\nmédicos', textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Obx(() {
      final client = controller.client.value;
      return Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: CustomColors.secundaryDarkerColor,
                    minimumSize: const Size(34, 34),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Ficha Clí­nica ${controller.isOdontology ? '(Odontologia)' : ''}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: CustomColors.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            controller.isLoadingClient.value
                ? const Text('Carregando cliente...')
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.person, size: 18),
                          const Text('Cliente: '),
                          Text(
                            client?.name ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('ID: ${client?.stringID ?? '-'}'),
                          const SizedBox(width: 8),
                          if (client?.currentAgeAsString.isNotEmpty == true)
                            Text('Idade: ${client!.currentAgeAsString}'),
                        ],
                      ),
                    ],
                  ),
          ],
        ),
      );
    });
  }

  Widget _historyTab() {
    if (controller.isLoadingHistory.value) return _loading();
    if (controller.appointments.isEmpty) {
      return _empty('Sem consultas realizadas.');
    }

    if (controller.isOdontology) {
      return _sectionList(
        title: 'Consultas realizadas',
        children: controller.appointments.map(_appointmentTile).toList(),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.loadHistory,
      child: ListView(
        primary: false,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(10),
        children: [
          _panel(
            title: 'Consultas realizadas',
            child: Column(
              children: controller.appointments.map(_appointmentTile).toList(),
            ),
          ),
          const SizedBox(height: 10),
          _panel(
            title: 'Serviços',
            child: Obx(() {
              if (controller.isLoadingServices.value) {
                return _loading(height: 90);
              }
              if (controller.selectedAppointment.value == null) {
                return _emptyInline('Seleccione uma consulta.');
              }
              if (controller.appointmentServices.isEmpty) {
                return _emptyInline(
                  'Sem serviços para a consulta seleccionada.',
                );
              }
              return Column(
                children: controller.appointmentServices
                    .map(_serviceTile)
                    .toList(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _digitalDocumentsTab() {
    if (controller.isLoadingDigitalDocuments.value) return _loading();
    if (controller.digitalDocuments.isEmpty) {
      return _empty('Sem documentos/imagens.');
    }
    return _sectionList(
      title: 'Documentos / Imagens',
      children: controller.digitalDocuments.map(_digitalDocumentTile).toList(),
      onRefresh: controller.loadDigitalDocuments,
    );
  }

  Widget _medicalDocumentsTab() {
    if (controller.isLoadingMedicalDocuments.value) return _loading();
    if (controller.medicalDocuments.isEmpty) {
      return _empty('Sem documentos médicos.');
    }
    return _sectionList(
      title: 'Documentos médicos',
      children: controller.medicalDocuments.map(_medicalDocumentTile).toList(),
      onRefresh: controller.loadMedicalDocuments,
    );
  }

  Widget _sectionList({
    required String title,
    required List<Widget> children,
    Future<void> Function()? onRefresh,
  }) {
    final list = ListView(
      primary: false,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      children: [
        _panel(
          title: title,
          child: Column(children: children),
        ),
      ],
    );
    if (onRefresh == null) {
      return list;
    }
    return RefreshIndicator(onRefresh: onRefresh, child: list);
  }

  Widget _appointmentTile(AppointmentDTO appointment) {
    final isSelected =
        controller.selectedAppointment.value?.id == appointment.id;
    return InkWell(
      onTap: controller.isOdontology
          ? null
          : () => controller.loadServices(appointment),
      child: Container(
        color: isSelected ? CustomColors.primaryLightColor : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDate(
                      appointment.startDate ?? appointment.creationDate,
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : CustomColors.textColor,
                    ),
                  ),
                ),
                Text(
                  appointment.state?.name ?? '-',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : CustomColors.mutedTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _mutedLine(
              'Médico',
              appointment.employeeName,
              selected: isSelected,
            ),
            _mutedLine(
              'Especialidade',
              appointment.medicalSpecialty?.name,
              selected: isSelected,
            ),
            _mutedLine('Sala', appointment.roomName, selected: isSelected),
            if (appointment.observations?.isNotEmpty == true)
              _mutedLine(
                'Observações',
                appointment.observations,
                selected: isSelected,
              ),
          ],
        ),
      ),
    );
  }

  Widget _serviceTile(AppointmentServiceDTO service) {
    return ListTile(
      dense: true,
      title: Text(
        service.serviceCodeAndName.isNotEmpty
            ? service.serviceCodeAndName
            : '-',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        [
          if (service.dateAsString.isNotEmpty) service.dateAsString,
          if (service.doctor.isNotEmpty) service.doctor,
          if (service.roomName.isNotEmpty) service.roomName,
          'Facturado: ${service.billed}',
        ].join(' | '),
      ),
    );
  }

  Widget _digitalDocumentTile(DigitalDocumentDTO document) {
    return ListTile(
      leading: Icon(_documentIcon(document.dataTypeID)),
      title: Text(document.name.isNotEmpty ? document.name : 'Documento'),
      subtitle: Text(
        [
          if (document.typeName.isNotEmpty) document.typeName,
          if (document.creationDateAsString.isNotEmpty)
            document.creationDateAsString,
        ].join(' | '),
      ),
    );
  }

  Widget _medicalDocumentTile(ClientMedicalDocumentDTO document) {
    return ListTile(
      leading: const Icon(Icons.description_outlined),
      title: Text(
        document.typeName.isNotEmpty
            ? document.typeName
            : 'Documento médico ${document.typeEnum ?? ''}',
      ),
      subtitle: Text(document.creationDateAsString),
    );
  }

  Widget _panel({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CustomColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              gradient: LinearGradient(
                colors: [
                  CustomColors.primaryDarkerColor,
                  CustomColors.secondaryColor,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _loading({double height = 180}) {
    return SizedBox(
      height: height,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _empty(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text,
          style: const TextStyle(color: CustomColors.mutedTextColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _emptyInline(String text) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Text(
        text,
        style: const TextStyle(color: CustomColors.mutedTextColor),
      ),
    );
  }

  Widget _mutedLine(String label, String? value, {bool selected = false}) {
    if (value?.isNotEmpty != true) return const SizedBox.shrink();
    return Text(
      '$label: $value',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: selected ? Colors.white : CustomColors.mutedTextColor,
        fontSize: 12,
      ),
    );
  }

  IconData _documentIcon(int? dataTypeID) {
    switch (dataTypeID) {
      case 1:
        return Icons.image_outlined;
      case 2:
        return Icons.picture_as_pdf_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return formatDate(date);
  }
}
