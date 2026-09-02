import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/index.dart';
import '../../../data/models/index.dart';
import '../../index.dart';

class UserPage extends GetView<UserController> {
  const UserPage({super.key});

  static const int _profileTabCount = 3;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(
      builder: (userController) => Scaffold(
        backgroundColor: CustomColors.backgroundColor,
        drawer: customDrawer(),
        body: Column(
          children: [
            customAppbar(),
            Expanded(child: _buildProfile(userController)),
          ],
        ),
        bottomNavigationBar: customMenu(alignBottom: false),
      ),
    );
  }

  Widget _buildProfile(UserController userController) {
    final user = userController.globalController.authenticatedUser.value;
    if (user == null) {
      return const Center(child: Text('Não foi possível carregar o perfil.'));
    }

    final displayName = user.shortName.trim().isNotEmpty
        ? user.shortName.trim()
        : user.name.trim();
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
    final employee =
        userController.globalController.authenticatedEmployee.value;
    final hasAssociatedEmployee =
        employee != null && employee.id > 0 && employee.userId == user.id;

    return RefreshIndicator(
      color: CustomColors.primaryColor,
      onRefresh: userController.loadStores,
      child: SingleChildScrollView(
        primary: false,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(displayName, user.groupName, initial),
            const SizedBox(height: 24),
            DefaultTabController(
              length: _profileTabCount,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileTabs(),
                  const SizedBox(height: 12),
                  Obx(() {
                    final personalInfo = [
                      _ProfileItem(Icons.person_outline, 'Nome', user.name),
                      _ProfileItem(
                        Icons.badge_outlined,
                        'Utilizador',
                        user.login,
                      ),
                      _ProfileItem(Icons.email_outlined, 'E-mail', user.email),
                      _ProfileItem(
                        Icons.phone_outlined,
                        'Telefone',
                        user.phone,
                      ),
                      _ProfileItem(
                        Icons.groups_outlined,
                        'Grupo',
                        user.groupName,
                      ),
                    ];

                    if (hasAssociatedEmployee) {
                      personalInfo.add(
                        _ProfileItem(
                          Icons.medical_services_outlined,
                          'Médico',
                          employee.shortName.trim().isNotEmpty
                              ? employee.shortName
                              : employee.name,
                        ),
                      );
                    }

                    return SizedBox(
                      height: Get.height * 0.56,
                      child: TabBarView(
                        children: [
                          _buildPersonalInfo(personalInfo, userController),
                          _buildProfessionalInfo(employee),
                          _buildStores(userController),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTabs() {
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
          Tab(icon: Icon(Icons.person_outline, size: 18), text: 'Dados'),
          Tab(
            icon: Icon(Icons.health_and_safety_outlined, size: 18),
            text: 'Especialidades',
          ),
          Tab(icon: Icon(Icons.business_outlined, size: 18), text: 'Locais'),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo(
    List<_ProfileItem> personalInfo,
    UserController userController,
  ) {
    return _buildTabContent(
      child: _buildInfoCard(
        personalInfo,
        scrollController: userController.personalInfoScrollController,
      ),
    );
  }

  Widget _buildHeader(String name, String groupName, String initial) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            CustomColors.primaryDarkerColor,
            CustomColors.secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CustomColors.primaryDarkerColor.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  groupName,
                  style: const TextStyle(
                    color: Color(0xffB9E8E2),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    List<_ProfileItem> items, {
    ScrollController? scrollController,
    bool? withFilter,
  }) {
    final content = Column(children: _buildInfoRows(items));

    return Container(
      decoration: BoxDecoration(
        color: CustomColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CustomColors.borderColor),
      ),
      child: scrollController == null
          ? content
          : ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: Get.height * ((withFilter ?? false) ? 0.44 : 0.515),
              ),
              child: Scrollbar(
                controller: scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                radius: const Radius.circular(8),
                thickness: 4,
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.only(right: 8),
                  child: content,
                ),
              ),
            ),
    );
  }

  List<Widget> _buildInfoRows(List<_ProfileItem> items) {
    return List.generate(items.length, (index) {
      final item = items[index];
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: CustomColors.blueLightColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    color: CustomColors.secondaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (item.hasLabel) ...[
                        SizedBox(height: Get.height * 0.01),
                        Text(
                          item.label!,
                          style: const TextStyle(
                            color: CustomColors.mutedTextColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                      SizedBox(height: Get.height * 0.01),
                      Text(
                        item.value.trim().isEmpty
                            ? 'Não informado'
                            : item.value,
                        style: const TextStyle(
                          color: CustomColors.textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (index < items.length - 1) const Divider(height: 1, indent: 67),
        ],
      );
    });
  }

  Widget _buildProfessionalInfo(EmployeeDTO? employee) {
    final specialtyNames =
        employee?.allowedAppointmentExecutionSpecialties
            .map((specialty) => specialty.name.trim())
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList() ??
        [];
    final filteredSpecialtyNames = _filterValues(
      specialtyNames,
      controller.specialtyFilter.value,
    );

    return _buildTabContent(
      filter: _buildFilterField(
        textController: controller.specialtyFilterController,
        hintText: 'Filtrar especialidades',
        hasValue: controller.specialtyFilter.value.isNotEmpty,
        onChanged: controller.setSpecialtyFilter,
        onClear: controller.clearSpecialtyFilter,
      ),
      child: specialtyNames.isEmpty
          ? _storeStatus(const Text('Nenhuma especialidade associada.'))
          : filteredSpecialtyNames.isEmpty
          ? _storeStatus(const Text('Nenhuma especialidade encontrada.'))
          : _buildInfoCard(
              filteredSpecialtyNames
                  .map(
                    (name) => _ProfileItem(
                      Icons.health_and_safety_outlined,
                      null,
                      name,
                    ),
                  )
                  .toList(),
              scrollController: controller.specialtyScrollController,
              withFilter: true,
            ),
    );
  }

  Widget _buildStores(UserController userController) {
    if (userController.isLoadingStores) {
      return _storeStatus(
        SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    if (userController.hasStoreError) {
      return _storeStatus(
        Column(
          children: [
            const Text('Não foi possível carregar os locais.'),
            TextButton(
              onPressed: userController.loadStores,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final storeNames = userController.userStoreNames;
    if (storeNames.isEmpty) {
      return _storeStatus(Text('Nenhum local associado.'));
    }
    final filteredStoreNames = userController.filteredUserStoreNames;

    return _buildTabContent(
      filter: _buildFilterField(
        textController: userController.storeFilterController,
        hintText: 'Filtrar locais',
        hasValue: userController.storeFilter.value.isNotEmpty,
        onChanged: userController.setStoreFilter,
        onClear: userController.clearStoreFilter,
      ),
      child: filteredStoreNames.isEmpty
          ? _storeStatus(const Text('Nenhum local encontrado.'))
          : _buildInfoCard(
              filteredStoreNames
                  .map(
                    (name) => _ProfileItem(Icons.business_outlined, null, name),
                  )
                  .toList(),
              scrollController: userController.storeScrollController,
              withFilter: true,
            ),
    );
  }

  Widget _buildTabContent({Widget? filter, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (filter != null) ...[filter, const SizedBox(height: 12)],
        child,
      ],
    );
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

  Widget _buildFilterField({
    required TextEditingController textController,
    required String hintText,
    required bool hasValue,
    required ValueChanged<String> onChanged,
    required VoidCallback onClear,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: CustomColors.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CustomColors.borderColor),
      ),
      child: TextField(
        controller: textController,
        cursorColor: CustomColors.primaryColor,
        onChanged: onChanged,
        style: const TextStyle(color: CustomColors.textColor, fontSize: 16),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(
            color: CustomColors.mutedTextColor,
            fontSize: 15,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: CustomColors.primaryDarkerColor,
            size: 20,
          ),
          suffixIcon: hasValue
              ? IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close, size: 20),
                  color: CustomColors.mutedTextColor,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _storeStatus(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: CustomColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CustomColors.borderColor),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: CustomColors.mutedTextColor),
        textAlign: TextAlign.center,
        child: child,
      ),
    );
  }
}

class _ProfileItem {
  final IconData icon;
  final String? label;
  final String value;

  const _ProfileItem(this.icon, this.label, this.value);

  bool get hasLabel => label?.trim().isNotEmpty == true;
}
