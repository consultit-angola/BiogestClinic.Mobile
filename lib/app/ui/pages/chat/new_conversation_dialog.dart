import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/index.dart';
import 'chat_dialog_utils.dart';

class NewConversationDialogController extends GetxController {
  NewConversationDialogController({required this.users});

  final List<UserDTO> users;
  final searchController = TextEditingController();
  final search = ''.obs;

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

  void selectUser(UserDTO user) {
    Get.back(result: user);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

class NewConversationDialog extends GetView<NewConversationDialogController> {
  const NewConversationDialog({super.key, required String tag})
    : dialogTag = tag;

  final String dialogTag;

  @override
  String get tag => dialogTag;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AlertDialog(
        title: const Text('Nova conversa'),
        content: SizedBox(
          width: double.maxFinite,
          height: dialogContentHeight(context, maxFraction: 0.6),
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
              const SizedBox(height: 8),
              Expanded(
                child: controller.visibleUsers.isEmpty
                    ? const Center(child: Text('Nenhum resultado'))
                    : ListView.builder(
                        primary: false,
                        itemCount: controller.visibleUsers.length,
                        itemBuilder: (context, index) {
                          final user = controller.visibleUsers[index];
                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(user.name),
                            subtitle: user.groupName.isEmpty
                                ? null
                                : Text(user.groupName),
                            onTap: () => controller.selectUser(user),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancelar')),
        ],
      ),
    );
  }
}
