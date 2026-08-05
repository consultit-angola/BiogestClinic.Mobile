import 'package:biogest_clinic_mobile/app/data/shared/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/index.dart';
import '../../routes/index.dart';
import '../index.dart';

Widget customAppbar({bool showUserMenu = true}) {
  final menuController = CustomMenuController();
  return SizedBox(
    width: Get.width,
    // Altura total para permitir el logo centrado
    height: Get.height * 0.16,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Parte superior (barra con título y ajustes)
        Container(
          height: Get.height * 0.08,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: CustomColors.primaryLightColor,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: Get.width * 0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'myBio',
                style: Get.textTheme.headlineMedium!.copyWith(
                  color: CustomColors.witheColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (showUserMenu)
                Obx(() {
                  final user = GlobalController.to.authenticatedUser.value;

                  if (user == null) {
                    return const SizedBox.shrink();
                  }

                  return GestureDetector(
                    onTap: () {
                      showMenu(
                        context: Get.context!,
                        position: RelativeRect.fromLTRB(
                          Get.width,
                          Get.height * 0.06,
                          0,
                          0,
                        ),
                        items: [
                          PopupMenuItem(
                            value: 'user',
                            child: Row(
                              children: [
                                const Icon(Icons.person),
                                SizedBox(width: Get.width * 0.02),
                                const Text('Utilizador info'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'cleanCache',
                            child: Row(
                              children: [
                                const Icon(Icons.delete_sweep_outlined),
                                SizedBox(width: Get.width * 0.02),
                                const Text('Limpar cache'),
                              ],
                            ),
                          ),
                          if (user.id == 1)
                            PopupMenuItem(
                              value: 'changeApi',
                              child: Row(
                                children: [
                                  const Icon(Icons.cloud_sync_outlined),
                                  SizedBox(width: Get.width * 0.02),
                                  const Text('Alterar API'),
                                ],
                              ),
                            ),
                          PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                const Icon(Icons.logout_rounded),
                                SizedBox(width: Get.width * 0.02),
                                const Text('Sair'),
                              ],
                            ),
                          ),
                        ],
                      ).then((value) {
                        switch (value) {
                          case 'user':
                            menuController.selectedPosItem.value = -1;
                            Get.toNamed(Routes.user);
                            break;
                          case 'logout':
                            GlobalController.to.logout();
                            break;
                          case 'cleanCache':
                            Preferences().clear();
                            Preferences().skipSplash = false;
                            Get.snackbar('Sucesso', 'Cache limpo com sucesso');
                            Get.offAllNamed(Routes.splash);
                            break;
                          case 'changeApi':
                            Get.toNamed(Routes.apiSettings);
                            break;
                        }
                      });
                    },
                    child: CircleAvatar(
                      radius: Get.width * 0.04,
                      backgroundColor: const Color(0xB6181818),
                      child: Text(
                        _getUserInitials(user.name),
                        style: TextStyle(
                          color: CustomColors.witheColor,
                          fontSize: Get.width * 0.035,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),

        // Logo centrado (sin usar Stack)
        Transform.translate(
          offset: Offset(0, -Get.height * 0.04),
          child: Container(
            height: Get.height * 0.08,
            width: Get.height * 0.08,
            decoration: BoxDecoration(
              color: CustomColors.witheColor,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 30,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/images/logo.svg',
                width: Get.width * 0.07,
                height: Get.height * 0.07,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

String _getUserInitials(String name) {
  final names = name.trim().split(RegExp(r'\s+'));
  if (names.isEmpty || names.first.isEmpty) return '';

  final firstInitial = names.first[0].toUpperCase();
  final lastInitial = names.length > 1 ? names.last[0].toUpperCase() : '';
  return '$firstInitial$lastInitial';
}
