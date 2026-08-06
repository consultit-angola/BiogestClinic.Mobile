import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/index.dart';
import '../../../data/models/index.dart';
import '../../../routes/index.dart';
import '../../index.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (homeController) => Scaffold(
        backgroundColor: CustomColors.backgroundColor,
        drawer: customDrawer(),
        body: Column(
          children: [
            customAppbar(),
            Expanded(
              child: Obx(
                () => RefreshIndicator(
                  onRefresh: homeController.loadToday,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 18),
                    children: [
                      _sectionTitle(
                        'Agenda de hoje',
                        action: 'Ver agenda',
                        onTap: () {
                          CustomMenuController.to.selectItem(1);
                          Get.toNamed(Routes.calendar);
                        },
                      ),
                      const SizedBox(height: 10),
                      _agendaMetrics(homeController),
                      const SizedBox(height: 20),
                      _sectionTitle('Próximos pacientes'),
                      const SizedBox(height: 10),
                      _patientsCard(homeController),
                      const SizedBox(height: 20),
                      _sectionTitle('Resumo do dia'),
                      const SizedBox(height: 10),
                      _summaryCard(homeController),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: customMenu(alignBottom: false),
      ),
    );
  }

  Widget _sectionTitle(String title, {String? action, VoidCallback? onTap}) =>
      Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: CustomColors.textColor,
              ),
            ),
          ),
          if (action != null)
            TextButton.icon(
              onPressed: onTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              iconAlignment: IconAlignment.end,
              icon: const Icon(
                Icons.calendar_month_outlined,
                size: 18,
                color: CustomColors.primaryColor,
              ),
              label: Text(
                action,
                style: const TextStyle(
                  fontSize: 15,
                  color: CustomColors.primaryColor,
                ),
              ),
            ),
        ],
      );

  Widget _agendaMetrics(HomeController homeController) => SizedBox(
    height: 124,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _metric(
          'Consultas\nagendadas',
          homeController.countStates(['Scheduled', 'Confirmed', 'ReScheduled']),
          Icons.event_available_outlined,
          CustomColors.primaryColor,
        ),
        const SizedBox(width: 6),
        _metric(
          'Consultas\ncanceladas',
          homeController.countStates(['Canceled', 'DeScheduled']),
          Icons.event_busy_outlined,
          CustomColors.tertiaryColor,
        ),
        const SizedBox(width: 6),
        _metric(
          'Não\ncomparecidas',
          homeController.countStates(['DidNotAttend']),
          Icons.person_off_outlined,
          CustomColors.warningColor,
        ),
        const SizedBox(width: 6),
        _metric(
          'Consultas\nconcluídas',
          homeController.countStates(['AllFinished', 'ServicesFinished']),
          Icons.task_alt_outlined,
          CustomColors.secondaryColor,
        ),
      ],
    ),
  );

  Widget _metric(String label, int value, IconData icon, Color color) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: CustomColors.borderColor),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0B000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 30),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: CustomColors.textColor,
                ),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 11,
                  color: CustomColors.textColor,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _patientsCard(HomeController homeController) {
    if (homeController.loading.value) {
      return _emptyCard('A carregar pacientes...');
    }
    final appointments = homeController.upcomingAppointments;
    if (appointments.isEmpty) {
      return _emptyCard('Sem próximos pacientes para hoje.');
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CustomColors.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0B000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var index = 0; index < appointments.length; index++) ...[
            _patientRow(appointments[index]),
            if (index < appointments.length - 1)
              const Divider(height: 1, indent: 12, endIndent: 12),
          ],
        ],
      ),
    );
  }

  Widget _patientRow(AppointmentDTO appointment) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              DateFormat('HH:mm').format(
                appointment.scheduleStartDate?.toLocal() ?? DateTime.now(),
              ),
              style: const TextStyle(
                color: CustomColors.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.clientName ?? 'Paciente',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: CustomColors.textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _serviceName(appointment),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: CustomColors.mutedTextColor,
                  ),
                ),
                if ((appointment.employeeName ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    appointment.employeeName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: CustomColors.mutedTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          _stateBadge(appointment),
        ],
      ),
    ),
  );

  String _serviceName(AppointmentDTO appointment) {
    final services = appointment.services
        ?.map((service) => service.serviceCodeAndName)
        .where((name) => name.isNotEmpty)
        .join(', ');
    return (services?.isNotEmpty ?? false)
        ? services!
        : appointment.medicalSpecialty?.name ?? 'Consulta';
  }

  Widget _stateBadge(AppointmentDTO appointment) {
    final label = appointment.state?.name ?? 'Agendada';
    final stateColor = appointment.stateColorRGB?.isNotEmpty == true
        ? Color(int.parse(appointment.stateColorRGB!.replaceAll('#', '0xFF')))
        : CustomColors.textColor;
    final needsTextShadow = stateColor.computeLuminance() > 0.6;
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 100),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: appointment.stateColorRGB?.isNotEmpty == true
              ? stateColor.withValues(alpha: 0.2)
              : CustomColors.blueLightColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: stateColor,
            fontWeight: FontWeight.w700,
            shadows: needsTextShadow
                ? const [
                    Shadow(
                      color: Color(0x99000000),
                      offset: Offset(0, 1),
                      blurRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(HomeController homeController) {
    final total = homeController.todayAppointments.length;
    final scheduled = homeController.countStates([
      'Scheduled',
      'Confirmed',
      'ReScheduled',
    ]);
    final concluded = homeController.countStates([
      'AllFinished',
      'ServicesFinished',
    ]);
    final inProgress = homeController.countStates(['BeingPerformed']);
    final canceled = homeController.countStates(['Canceled', 'DeScheduled']);
    final absent = homeController.countStates(['DidNotAttend']);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CustomColors.borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _summaryValue('Total', total),
              _summaryValue('Marcadas', scheduled),
              _summaryValue('Em realização', inProgress),
              _summaryValue('Concluídas', concluded),
              _summaryValue('Canceladas', canceled),
            ],
          ),
          const Divider(height: 24),
          _progressRow(
            'Progresso dos atendimentos',
            concluded,
            total,
            CustomColors.primaryColor,
          ),
          const SizedBox(height: 14),
          _progressRow(
            'Canceladas e não comparecidas',
            canceled + absent,
            total,
            CustomColors.tertiaryColor,
          ),
        ],
      ),
    );
  }

  Widget _summaryValue(String label, int value) => Expanded(
    child: Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: CustomColors.textColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            color: CustomColors.mutedTextColor,
          ),
        ),
      ],
    ),
  );

  Widget _progressRow(String label, int value, int total, Color color) {
    final progress = total == 0 ? 0.0 : value / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: CustomColors.mutedTextColor,
                ),
              ),
            ),
            Text(
              '$value de $total',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: CustomColors.textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: CustomColors.borderColor,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _emptyCard(String text) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: CustomColors.borderColor),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 11, color: CustomColors.mutedTextColor),
    ),
  );
}
