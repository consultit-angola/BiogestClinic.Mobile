import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/index.dart';
import '../../../data/models/index.dart';
import '../../index.dart';

class ClinicalRecordAppointmentDetailPage
    extends GetView<ClinicalRecordAppointmentDetailController> {
  const ClinicalRecordAppointmentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.backgroundColor,
      body: Column(
        children: [
          customAppbar(),
          _header(),
          Expanded(
            child: Obx(() {
              final appointment = controller.appointment.value;
              if (appointment == null) {
                return _empty('Consulta não encontrada.');
              }

              return RefreshIndicator(
                onRefresh: controller.loadServices,
                child: ListView(
                  primary: false,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(10),
                  children: [
                    _panel(
                      title: 'Dados da consulta',
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            _detailRow(
                              'Data',
                              _formatDate(
                                appointment.startDate ??
                                    appointment.creationDate,
                              ),
                            ),
                            _detailRow('Estado', appointment.state?.name),
                            _detailRow('Tipo', appointment.type?.name),
                            _detailRow('Médico', appointment.employeeName),
                            _detailRow(
                              'Especialidade',
                              appointment.medicalSpecialty?.name,
                            ),
                            _detailRow('Sala', appointment.roomName),
                            _detailRow('Local', appointment.storeName),
                            _detailRow('Cliente', appointment.clientName),
                            _detailRow(
                              'Emergência',
                              appointment.isEmergency == null
                                  ? null
                                  : appointment.isEmergency!
                                  ? 'Sim'
                                  : 'Não',
                            ),
                            _detailRow('Observações', appointment.observations),
                            _detailRow('Resumo', appointment.summary),
                            _diagnosticCodes(appointment.diagnosticCodes),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _panel(title: 'Serviços', child: _servicesContent()),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
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
            'Detalhe da consulta',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: CustomColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _servicesContent() {
    return Obx(() {
      if (controller.isLoadingServices.value) return _loading(height: 90);
      if (controller.services.isEmpty) {
        return _emptyInline('Sem serviços para esta consulta.');
      }
      return Column(children: controller.services.map(_serviceTile).toList());
    });
  }

  Widget _serviceTile(AppointmentServiceDTO service) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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

  Widget _diagnosticCodes(List<DiagnosticCodeDTO>? codes) {
    final values =
        codes
            ?.map((code) => code.codeAndName ?? code.name ?? code.code ?? '')
            .where((value) => value.trim().isNotEmpty)
            .toList() ??
        [];
    if (values.isEmpty) return const SizedBox.shrink();
    return _detailRow('Diagnósticos', values.join('\n'));
  }

  Widget _detailRow(String label, String? value) {
    if (value?.trim().isNotEmpty != true) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: CustomColors.mutedTextColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value!,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: CustomColors.textColor,
              ),
            ),
          ),
        ],
      ),
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

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return formatDate(date);
  }
}
