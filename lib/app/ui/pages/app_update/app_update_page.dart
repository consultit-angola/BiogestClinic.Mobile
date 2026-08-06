import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../controllers/app_update_controller.dart';
import '../../utils/custom_colors.dart';

class AppUpdatePage extends GetView<AppUpdateController> {
  const AppUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppUpdateController>(
      builder: (updateController) {
        if (updateController.status == AppUpdateStatus.checking) {
          return const Scaffold(
            backgroundColor: CustomColors.primaryDarkerColor,
          );
        }

        final release = updateController.release!;
        final isDownloading =
            updateController.status == AppUpdateStatus.downloading;
        final isDownloaded =
            updateController.status == AppUpdateStatus.downloaded;

        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: CustomColors.backgroundColor,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SvgPicture.asset(
                        'assets/images/logo.svg',
                        height: 42,
                      ),
                    ),
                    const SizedBox(height: 36),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: CustomColors.blueLightColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.system_update_alt_rounded,
                        color: CustomColors.primaryColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Nova atualização disponível',
                      style: TextStyle(
                        color: CustomColors.textColor,
                        fontFamily: 'OpenSans',
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Escolha quando pretende descarregar e instalar.',
                      style: TextStyle(
                        color: CustomColors.mutedTextColor,
                        fontFamily: 'OpenSans',
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _VersionCard(
                            label: 'Versão atual',
                            version: release.currentVersion,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: CustomColors.mutedTextColor,
                          ),
                        ),
                        Expanded(
                          child: _VersionCard(
                            label: 'Nova versão',
                            version: release.version,
                            highlighted: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Melhorias',
                      style: TextStyle(
                        color: CustomColors.textColor,
                        fontFamily: 'OpenSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          release.releaseNotes.isEmpty
                              ? 'Melhorias de desempenho e estabilidade.'
                              : release.releaseNotes,
                          style: const TextStyle(
                            color: CustomColors.mutedTextColor,
                            fontFamily: 'OpenSans',
                            fontSize: 14,
                            height: 1.55,
                          ),
                        ),
                      ),
                    ),
                    if (isDownloading || isDownloaded) ...[
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: updateController.downloadProgress,
                                minHeight: 9,
                                backgroundColor: CustomColors.borderColor,
                                color: CustomColors.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${(updateController.downloadProgress * 100).round()}%',
                            style: const TextStyle(
                              color: CustomColors.textColor,
                              fontFamily: 'OpenSans',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (updateController.status == AppUpdateStatus.error) ...[
                      const SizedBox(height: 14),
                      const Text(
                        'Não foi possível descarregar. Verifique a ligação e tente novamente.',
                        style: TextStyle(
                          color: CustomColors.tertiaryColor,
                          fontFamily: 'OpenSans',
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: updateController.continueWithoutUpdating,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: CustomColors.textColor,
                              minimumSize: const Size.fromHeight(54),
                              side: const BorderSide(
                                color: CustomColors.borderColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              isDownloading
                                  ? 'Cancelar descarga'
                                  : isDownloaded
                                  ? 'Cancelar e continuar'
                                  : 'Continuar sem atualizar',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: isDownloading
                                ? null
                                : isDownloaded
                                ? updateController.installUpdate
                                : updateController.startDownload,
                            style: FilledButton.styleFrom(
                              backgroundColor: CustomColors.secondaryColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: CustomColors.borderColor,
                              minimumSize: const Size.fromHeight(54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              isDownloading
                                  ? 'A descarregar...'
                                  : isDownloaded
                                  ? 'Instalar'
                                  : 'Iniciar descarga',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VersionCard extends StatelessWidget {
  const _VersionCard({
    required this.label,
    required this.version,
    this.highlighted = false,
  });

  final String label;
  final String version;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlighted ? CustomColors.blueLightColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted
              ? CustomColors.primaryColor
              : CustomColors.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: CustomColors.mutedTextColor,
              fontFamily: 'OpenSans',
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            version,
            style: const TextStyle(
              color: CustomColors.textColor,
              fontFamily: 'OpenSans',
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
