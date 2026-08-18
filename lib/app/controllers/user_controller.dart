import 'package:get/get.dart';

import '../data/models/index.dart';
import '../data/providers/provider.dart';
import 'index.dart';

class UserController extends GetxController {
  static UserController get to => Get.find<UserController>();
  final globalController = GlobalController.to;
  final Provider _provider = Provider();

  List<StoreDTO> stores = [];
  bool isLoadingStores = false;
  bool hasStoreError = false;

  Future<void> loadStores() async {
    isLoadingStores = true;
    hasStoreError = false;
    update();

    final response = await _provider.getStores();
    if (response['ok'] == true) {
      stores = response['data'] as List<StoreDTO>;
    } else {
      hasStoreError = true;
    }

    isLoadingStores = false;
    update();
  }

  List<String> get userStoreNames {
    final storeIds = globalController.authenticatedUser.value?.storeIds ?? [];
    return stores
        .where((store) => storeIds.contains(store.id))
        .map((store) => store.name)
        .where((name) => name.trim().isNotEmpty)
        .toList();
  }
}
