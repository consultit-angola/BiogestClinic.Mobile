import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/index.dart';
import '../../data/shared/index.dart';
import '../../routes/index.dart';
import '../index.dart';

class ApiSettingsPage extends StatefulWidget {
  const ApiSettingsPage({super.key});

  @override
  State<ApiSettingsPage> createState() => _ApiSettingsPageState();
}

class _ApiSettingsPageState extends State<ApiSettingsPage> {
  late String _selectedApiName;

  @override
  void initState() {
    super.initState();
    _selectedApiName = ApiConfig.activeApiName;
  }

  Future<void> _saveApiSelection() async {
    final previousApiName = ApiConfig.activeApiName;
    if (_selectedApiName == previousApiName) {
      Get.snackbar('Informação', 'A API selecionada já está ativa');
      return;
    }

    await ApiConfig.setActiveApiName(_selectedApiName);

    final globalController = GlobalController.to;
    globalController.stopTimer();
    globalController.authenticatedUser.value = null;
    globalController.authenticatedEmployee.value = null;
    globalController.isAuthenticated.value = false;

    await Preferences().clear();
    Preferences().skipSplash = false;

    if (!mounted) {
      return;
    }

    Get.snackbar(
      'Sucesso',
      'API alterada para $_selectedApiName. Inicie sessão novamente.',
    );
    Get.offAllNamed(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    final availableApiNames = ApiConfig.availableApiNames;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CustomColors.witheColor,
                  CustomColors.secondaryColor.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
          Column(children: [customAppbar()]),
          Padding(
            padding: EdgeInsets.only(
              top: Get.height * 0.18,
              left: Get.width * 0.06,
              right: Get.width * 0.06,
              bottom: Get.height * 0.04,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuração de API',
                  style: Get.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Get.height * 0.01),
                Text(
                  'Escolha o ambiente publicado que a aplicação deve usar neste dispositivo.',
                  style: Get.textTheme.bodyMedium,
                ),
                SizedBox(height: Get.height * 0.02),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'API atual: ${ApiConfig.activeApiName}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          ApiConfig.activeApiUrl,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: Get.height * 0.02),
                Expanded(
                  child: Card(
                    child: ListView(
                      children: availableApiNames.map((apiName) {
                        final isSelected = apiName == _selectedApiName;
                        return ListTile(
                          leading: Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected
                                ? CustomColors.primaryLightColor
                                : null,
                          ),
                          title: Text(apiName),
                          subtitle: Text(
                            ApiConfig.buildApiUrl(apiName),
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedApiName = apiName;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveApiSelection,
                    child: const Text('Guardar e reiniciar sessão'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
