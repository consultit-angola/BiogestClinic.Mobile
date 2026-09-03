import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/index.dart';
import '../../../data/models/index.dart';
import '../../index.dart';

class ClientManagementPage extends GetView<ClientManagementController> {
  const ClientManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: CustomColors.backgroundColor,
      drawer: customDrawer(),
      body: Column(
        children: [
          customAppbar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 18),
              child: Column(
                children: [
                  const Text(
                    'Gestão de Clientes',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CustomColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _searchBox(),
                  const SizedBox(height: 14),
                  Expanded(child: _clientList()),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isKeyboardVisible
          ? null
          : customMenu(alignBottom: false),
    );
  }

  Widget _searchBox() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: Get.height * 0.05,
            padding: const EdgeInsets.all(2), // Border size
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(45)),
              gradient: LinearGradient(
                colors: [
                  CustomColors.primaryDarkerColor,
                  CustomColors.secondaryColor,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(Get.context!).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(43),
              ),
              child: TextField(
                controller: controller.searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => controller.searchClients(),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  labelText: ' Nome ou ID do cliente',
                  floatingLabelStyle: TextStyle(
                    backgroundColor: Theme.of(
                      Get.context!,
                    ).scaffoldBackgroundColor,
                  ),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(43)),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(43)),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(43)),
                    borderSide: BorderSide.none,
                  ),
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  isDense: true,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Obx(
          () => SizedBox(
            height: 48,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(45)),
                gradient: LinearGradient(
                  colors: [
                    CustomColors.primaryDarkerColor,
                    CustomColors.secondaryColor,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.searchClients,
                icon: controller.isLoading.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.search),
                label: const Text('Pesquisar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white54,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: const StadiumBorder(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _clientList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.only(top: 70),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.clients.isEmpty) {
        return Container(
          height: 220,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: CustomColors.borderColor),
          ),
          child: Text(
            controller.hasSearched.value
                ? 'Nenhum cliente encontrado.'
                : 'A lista aparece vazia até pesquisar.',
            style: const TextStyle(color: CustomColors.mutedTextColor),
            textAlign: TextAlign.center,
          ),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: CustomColors.borderColor),
        ),
        child: Column(
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
              child: const Text(
                'Lista de Clientes',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: controller.clients.map(_clientTile).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _clientTile(ClientDTO client) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
          leading: PopupMenuButton<_ClientAction>(
            icon: const Icon(Icons.more_vert),
            onSelected: (action) => _handleAction(action, client),
            itemBuilder: (_) => [
              // _menuItem(_ClientAction.edit, Icons.edit, 'Editar'),
              // _menuItem(
              //   _ClientAction.currentAccount,
              //   Icons.trending_up,
              //   'Conta Corrente',
              // ),
              // _menuItem(_ClientAction.balance, Icons.attach_money, 'Saldo'),
              // _menuItem(_ClientAction.delete, Icons.delete, 'Eliminar'),
              // _menuItem(_ClientAction.merge, Icons.merge_type, 'Juntar'),
              _menuItem(
                _ClientAction.clinicalRecord,
                Icons.medical_services,
                'Ficha Clínica',
              ),
              // _menuItem(
              //   _ClientAction.followUp,
              //   Icons.assignment,
              //   'Acompanhamento',
              // ),
              _menuItem(
                _ClientAction.whatsApp,
                Icons.chat_bubble_outline,
                'Contactar via WhatsApp',
              ),
            ],
          ),
          title: Text(
            client.nameWithEntity.isNotEmpty
                ? client.nameWithEntity
                : client.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 10,
              runSpacing: 4,
              children: [
                _detail('N.º Cliente', client.stringID),
                if (client.phoneNumber.isNotEmpty)
                  _detail('Telefone', client.phoneNumber),
                if (client.entityAsString.isNotEmpty)
                  _detail('Entidade', client.entityAsString),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: CustomColors.borderColor),
      ],
    );
  }

  PopupMenuItem<_ClientAction> _menuItem(
    _ClientAction action,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem(
      value: action,
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 22),
          const SizedBox(width: 14),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Text(
      '$label: ${value.isEmpty ? '-' : value}',
      style: const TextStyle(color: CustomColors.mutedTextColor, fontSize: 12),
    );
  }

  void _handleAction(_ClientAction action, ClientDTO client) {
    FocusManager.instance.primaryFocus?.unfocus();

    switch (action) {
      case _ClientAction.edit:
        controller.showActionUnavailable('Editar');
      case _ClientAction.currentAccount:
        controller.showActionUnavailable('Conta Corrente');
      case _ClientAction.balance:
        controller.showActionUnavailable('Saldo');
      case _ClientAction.delete:
        controller.showActionUnavailable('Eliminar');
      case _ClientAction.merge:
        controller.showActionUnavailable('Juntar');
      case _ClientAction.clinicalRecord:
        _openClinicalRecordDialog(client);
      case _ClientAction.followUp:
        controller.showActionUnavailable('Acompanhamento');
      case _ClientAction.whatsApp:
        controller.contactViaWhatsApp(client);
    }
  }

  void _openClinicalRecordDialog(ClientDTO client) {
    FocusManager.instance.primaryFocus?.unfocus();

    Get.dialog<void>(
      Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    CustomColors.primaryDarkerColor,
                    CustomColors.secondaryColor,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Especialidade Médica',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _clinicalRecordOption(
                      icon: Icons.masks,
                      label: 'Odontologia',
                      onTap: () {
                        Get.back();
                        controller.openClinicalRecord(
                          client,
                          ClinicalRecordType.odontology,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _clinicalRecordOption(
                      icon: Icons.medical_services,
                      label: 'Especialidades',
                      onTap: () {
                        Get.back();
                        controller.openClinicalRecord(
                          client,
                          ClinicalRecordType.specialties,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _clinicalRecordOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 112,
        decoration: BoxDecoration(
          color: CustomColors.primaryLightColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 38),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ClientAction {
  edit,
  currentAccount,
  balance,
  delete,
  merge,
  clinicalRecord,
  followUp,
  whatsApp,
}
