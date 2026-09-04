import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:gradient_coloured_buttons/gradient_coloured_buttons.dart';

import '../../../controllers/index.dart';
import '../../index.dart';

class CreateAppointmentPage extends GetView<AppointmentCreateController> {
  const CreateAppointmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppointmentCreateController>(
      builder: (_) => Scaffold(
        backgroundColor: CustomColors.backgroundColor,
        appBar: AppBar(
          title: const Text('Nova marcação'),
          backgroundColor: CustomColors.primaryDarkerColor,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: ListView(
            primary: false,
            padding: const EdgeInsets.all(16),
            children: [
              _dateTimeTile(
                context: context,
                icon: Icons.event,
                label: 'Dia',
                value: DateFormat('dd/MM/yyyy').format(controller.selectedDate),
                onTap: () => _pickDate(context),
              ),
              Row(
                children: [
                  Expanded(
                    child: _dateTimeTile(
                      context: context,
                      icon: Icons.schedule,
                      label: 'Início',
                      value: controller.startTime.format(context),
                      onTap: () => _pickStartTime(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dateTimeTile(
                      context: context,
                      icon: Icons.schedule,
                      label: 'Fim',
                      value: controller.endTime.format(context),
                      onTap: () => _pickEndTime(context),
                    ),
                  ),
                ],
              ),
              CustomSingleSelectField(
                label: 'Cliente',
                options: controller.clients,
                value: controller.clientID,
                loading: controller.loadingClients,
                searchable: true,
                onRemoteSearch: (name) async {
                  await controller.searchClients(name);
                  return controller.clients;
                },
                onRefresh: null,
                onChanged: controller.selectClient,
                withEmptyOptionText: false,
              ),
              CustomSingleSelectField(
                label: 'Médico',
                options: controller.employees,
                value: controller.employeeID,
                loading: controller.loadingEmployees,
                searchable: true,
                emptyOptionText: 'Médico',
                onRefresh: null,
                onChanged: controller.selectEmployee,
                withEmptyOptionText: false,
              ),
              CustomSingleSelectField(
                label: 'Especialidade',
                options: controller.medicalSpecialties,
                value: controller.medicalSpecialtyID,
                loading: controller.loadingMedicalSpecialties,
                searchable: true,
                emptyOptionText: 'Especialidade',
                onRefresh: null,
                onChanged: controller.selectMedicalSpecialty,
                withEmptyOptionText: false,
              ),
              CustomSingleSelectField(
                label: 'Local',
                options: controller.stores,
                value: controller.storeID,
                loading: controller.loadingStores,
                emptyOptionText: 'Local',
                onRefresh: null,
                onChanged: controller.selectStore,
                withEmptyOptionText: false,
              ),
              CustomSingleSelectField(
                label: 'Sala',
                options: controller.rooms,
                value: controller.roomID,
                loading: controller.loadingRooms,
                searchable: true,
                emptyOptionText: 'Sala',
                onRefresh: null,
                onChanged: controller.selectRoom,
                withEmptyOptionText: false,
              ),
              _servicesField(context),
              TextField(
                controller: controller.observationsController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: Get.height * 0.08),
            ],
          ),
        ),
        floatingActionButton: GradientButton(
          width: Get.width * 0.9,
          text: 'Criar marcação',
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.white,
          ),
          gradientColors: [
            CustomColors.primaryDarkerColor,
            CustomColors.secondaryColor,
          ],
          borderRadius: 45,
          onPressed: () async {
            if (controller.clientID == null ||
                controller.employeeID == null ||
                controller.medicalSpecialtyID == null ||
                controller.storeID == null ||
                controller.roomID == null) {
              AppToast.show(
                'Erro',
                'Por favor, preencha todos os campos obrigatórios.',
                backgroundColor: Colors.red,
              );
              return;
            }
            final isValidTimeRange =
                controller.startTime.hour < controller.endTime.hour ||
                (controller.startTime.hour == controller.endTime.hour &&
                    controller.startTime.minute < controller.endTime.minute);
            if (!isValidTimeRange) {
              AppToast.show(
                'Erro',
                'O horário de início deve ser anterior ao horário de fim.',
                backgroundColor: Colors.red,
              );
              return;
            }
            // final hasOverlappingAppointments = await controller
            //     .checkOverlappingAppointments();
            // if (hasOverlappingAppointments) {
            //   AppToast.show(
            //     'Erro',
            //     'O horário selecionado sobrepõe-se a outra marcação.',
            //     backgroundColor: Colors.red,
            //   );
            //   return;
            // }
            // final hasOverlappingAppointmentsForEmployee = await controller
            //     .checkOverlappingAppointmentsForEmployee();
            // if (hasOverlappingAppointmentsForEmployee) {
            //   AppToast.show(
            //     'Erro',
            //     'O horário selecionado sobrepõe-se a outra marcação para o mesmo médico.',
            //     backgroundColor: Colors.red,
            //   );
            //   return;
            // }
            // final hasOverlappingAppointmentsForRoom = await controller
            //     .checkOverlappingAppointmentsForRoom();
            // if (hasOverlappingAppointmentsForRoom) {
            //   AppToast.show(
            //     'Erro',
            //     'O horário selecionado sobrepõe-se a outra marcação para a mesma sala.',
            //     backgroundColor: Colors.red,
            //   );
            //   return;
            // }

            final created = await controller.save();
            if (created) Get.back();
          },
        ),
      ),
    );
  }

  Widget _servicesField(BuildContext context) {
    final canEdit = controller.canEditServices;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomMultiSelectField(
            label: 'Serviços',
            options: controller.serviceFilterOptions,
            selectedIDs: controller.selectedServiceIDs,
            loading: controller.loadingServices,
            onRefresh: null,
            onChanged: controller.updateSelectedServices,
            selectedTextOverride: controller.selectedServices.isEmpty
                ? null
                : controller.selectedServicesText,
            maxLines: 5,
            withEmptyOptionText: false,
            enabled: canEdit,
            onBeforeOpen: () => controller.searchServices(''),
            remoteSearchMinLength: 0,
            onRemoteSearch: (search) async {
              await controller.searchServices(search);
              return controller.serviceFilterOptions;
            },
            optionsBuilder: (context, options, selected, onSelectionChanged) =>
                ServiceTreeMultiSelect(
                  options: options,
                  selectedIDs: selected,
                  onLoadGroupServices: controller.loadGroupServices,
                  onLoadMoreGroupServices: controller.loadMoreGroupServices,
                  hasMoreGroupServices: controller.hasMoreGroupServices,
                  onSelectionChanged: onSelectionChanged,
                  searchTerm: controller.serviceSearch,
                ),
          ),
          if (!canEdit && controller.selectedServices.isEmpty)
            const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                'Selecione cliente, médico e sala para adicionar serviços.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _dateTimeTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            prefixIcon: Icon(icon, color: CustomColors.primaryDarkerColor),
          ),
          child: Text(value),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      controller.selectDate(picked);
    }
  }

  Future<void> _pickStartTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: controller.startTime,
    );
    if (picked != null) {
      controller.selectStartTime(picked);
    }
  }

  Future<void> _pickEndTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: controller.endTime,
    );
    if (picked != null) {
      controller.selectEndTime(picked);
    }
  }
}
