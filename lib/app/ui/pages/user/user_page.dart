import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/index.dart';
import '../../../data/models/index.dart';
import '../../index.dart';

class UserPage extends GetView<UserController> {
  const UserPage({super.key});

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
            const _SectionTitle('Dados pessoais'),
            const SizedBox(height: 10),
            _buildInfoCard([
              _ProfileItem(Icons.person_outline, 'Nome', user.name),
              _ProfileItem(Icons.badge_outlined, 'Utilizador', user.login),
              _ProfileItem(Icons.email_outlined, 'E-mail', user.email),
              _ProfileItem(Icons.phone_outlined, 'Telefone', user.phone),
              _ProfileItem(Icons.groups_outlined, 'Grupo', user.groupName),
            ]),
            if (hasAssociatedEmployee) ...[
              const SizedBox(height: 22),
              const _SectionTitle('Dados profissionais'),
              const SizedBox(height: 10),
              _buildProfessionalInfo(employee),
            ],
            const SizedBox(height: 22),
            const _SectionTitle('Locales associados'),
            const SizedBox(height: 10),
            _buildStores(userController),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalInfo(EmployeeDTO employee) {
    final employeeName = employee.shortName.trim().isNotEmpty
        ? employee.shortName
        : employee.name;
    final specialtyNames = employee.allowedAppointmentExecutionSpecialties
        .map((specialty) => specialty.name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    return _buildInfoCard([
      _ProfileItem(Icons.medical_services_outlined, 'Médico', employeeName),
      ...specialtyNames.map(
        (name) => _ProfileItem(
          Icons.health_and_safety_outlined,
          'Especialidade',
          name,
        ),
      ),
      if (specialtyNames.isEmpty)
        const _ProfileItem(
          Icons.health_and_safety_outlined,
          'Especialidades',
          'Nenhuma especialidade associada',
        ),
    ]);
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

  Widget _buildInfoCard(List<_ProfileItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: CustomColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CustomColors.borderColor),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
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
                        children: [
                          Text(
                            item.label,
                            style: const TextStyle(
                              color: CustomColors.mutedTextColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.value.trim().isEmpty
                                ? 'Não informado'
                                : item.value,
                            style: const TextStyle(
                              color: CustomColors.textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (index < items.length - 1)
                const Divider(height: 1, indent: 67),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStores(UserController userController) {
    if (userController.isLoadingStores) {
      return const _StoreStatus(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    if (userController.hasStoreError) {
      return _StoreStatus(
        child: Column(
          children: [
            const Text('Não foi possível carregar os locales.'),
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
      return const _StoreStatus(child: Text('Nenhum local associado.'));
    }

    return _buildInfoCard(
      storeNames
          .map((name) => _ProfileItem(Icons.business_outlined, 'Local', name))
          .toList(),
    );
  }
}

class _ProfileItem {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileItem(this.icon, this.label, this.value);
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: CustomColors.textColor,
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _StoreStatus extends StatelessWidget {
  final Widget child;

  const _StoreStatus({required this.child});

  @override
  Widget build(BuildContext context) {
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
