import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/index.dart';
import 'chat_dialog_utils.dart';

class BroadcastRequest {
  const BroadcastRequest({required this.users, required this.message});

  final List<UserDTO> users;
  final String message;
}

class BroadcastDialogController extends GetxController {
  BroadcastDialogController({required this.users});

  final List<UserDTO> users;
  final searchController = TextEditingController();
  final messageController = TextEditingController();
  final search = ''.obs;
  final message = ''.obs;
  final selectedUserIDs = <int>{}.obs;

  List<UserDTO> get visibleUsers {
    final query = search.value.toLowerCase();
    return users
        .where(
          (user) =>
              user.name.toLowerCase().contains(query) ||
              user.groupName.toLowerCase().contains(query),
        )
        .toList();
  }

  bool get allSelected =>
      users.isNotEmpty &&
      users.every((user) => selectedUserIDs.contains(user.id));

  bool get canSend =>
      selectedUserIDs.isNotEmpty && message.value.trim().isNotEmpty;

  void toggleAll(bool selected) {
    if (selected) {
      selectedUserIDs.addAll(users.map((user) => user.id));
    } else {
      selectedUserIDs.clear();
    }
  }

  void toggleUser(UserDTO user, bool selected) {
    if (selected) {
      selectedUserIDs.add(user.id);
    } else {
      selectedUserIDs.remove(user.id);
    }
  }

  void send() {
    if (!canSend) return;

    Get.back(
      result: BroadcastRequest(
        users: users
            .where((user) => selectedUserIDs.contains(user.id))
            .toList(),
        message: messageController.text.trim(),
      ),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    messageController.dispose();
    super.onClose();
  }
}

class BroadcastDialog extends GetView<BroadcastDialogController> {
  const BroadcastDialog({super.key, required String tag}) : dialogTag = tag;

  final String dialogTag;

  @override
  String get tag => dialogTag;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AlertDialog(
        title: const Text('Nova mensagem de difusão'),
        content: SizedBox(
          width: double.maxFinite,
          height: dialogContentHeight(context, maxFraction: 0.7),
          child: Column(
            children: [
              TextField(
                controller: controller.searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Pesquisar empregado',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => controller.search.value = value.trim(),
              ),
              CheckboxListTile(
                value: controller.allSelected,
                title: const Text('Selecionar todos'),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (checked) => controller.toggleAll(checked == true),
              ),
              Expanded(
                child: controller.visibleUsers.isEmpty
                    ? const Center(child: Text('Nenhum resultado'))
                    : ListView.builder(
                        primary: false,
                        itemCount: controller.visibleUsers.length,
                        itemBuilder: (context, index) {
                          final user = controller.visibleUsers[index];
                          return CheckboxListTile(
                            value: controller.selectedUserIDs.contains(user.id),
                            title: Text(user.name),
                            subtitle: user.groupName.isEmpty
                                ? null
                                : Text(user.groupName),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (checked) =>
                                controller.toggleUser(user, checked == true),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.messageController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Mensagem',
                  hintText: 'Escreva a mensagem aqui',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => controller.message.value = value.trim(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancelar')),
          ElevatedButton.icon(
            onPressed: controller.canSend ? controller.send : null,
            icon: const Icon(Icons.send),
            label: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
