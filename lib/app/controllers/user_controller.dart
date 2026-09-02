import 'package:flutter/widgets.dart';
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
  final RxString specialtyFilter = ''.obs;
  final RxString storeFilter = ''.obs;
  final TextEditingController specialtyFilterController =
      TextEditingController();
  final TextEditingController storeFilterController = TextEditingController();
  final ScrollController personalInfoScrollController = ScrollController();
  final ScrollController specialtyScrollController = ScrollController();
  final ScrollController storeScrollController = ScrollController();

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

  List<String> get filteredUserStoreNames {
    return _filterValues(userStoreNames, storeFilter.value);
  }

  void setSpecialtyFilter(String value) {
    specialtyFilter.value = value.trim().toLowerCase();
  }

  void setStoreFilter(String value) {
    storeFilter.value = value.trim().toLowerCase();
  }

  void clearSpecialtyFilter() {
    specialtyFilterController.clear();
    specialtyFilter.value = '';
  }

  void clearStoreFilter() {
    storeFilterController.clear();
    storeFilter.value = '';
  }

  List<String> _filterValues(List<String> values, String filter) {
    final normalizedFilter = filter.trim().toLowerCase();
    if (normalizedFilter.isEmpty) {
      return values;
    }

    return values
        .where((value) => value.toLowerCase().contains(normalizedFilter))
        .toList();
  }

  @override
  void onClose() {
    specialtyFilterController.dispose();
    storeFilterController.dispose();
    personalInfoScrollController.dispose();
    specialtyScrollController.dispose();
    storeScrollController.dispose();
    super.onClose();
  }
}
