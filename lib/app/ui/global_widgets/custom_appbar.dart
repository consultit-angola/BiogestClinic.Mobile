import 'package:biogest_clinic_movile/app/data/shared/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../controllers/index.dart';
import '../../routes/index.dart';
import '../index.dart';

Widget customAppbar({showSettings = false}) {
  return Stack(
    children: [
      Container(
        height: Get.height * 0.08,
        width: Get.width,
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
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: Get.width * 0.1),
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
              showSettings
                  ? GestureDetector(
                      onTapDown: (TapDownDetails details) {
                        showMenu(
                          context: Get.context!,
                          position: RelativeRect.fromLTRB(
                            details.globalPosition.dx,
                            details.globalPosition.dy,
                            0,
                            0,
                          ),
                          items: [
                            PopupMenuItem(
                              value: 'cleanCache',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_sweep_outlined),
                                  SizedBox(width: Get.width * 0.02),
                                  Text('Limpar cache'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(Icons.logout_rounded),
                                  SizedBox(width: Get.width * 0.02),
                                  Text('Sair'),
                                ],
                              ),
                            ),
                          ],
                        ).then((value) {
                          switch (value) {
                            case 'logout':
                              GlobalController.to.logout();
                              break;
                            case 'cleanCache':
                              Preferences().clear();
                              Preferences().skipSplash = false;

                              Get.snackbar(
                                'Sucesso',
                                'Cache limpo com sucesso',
                              );
                              Get.offAllNamed(Routes.splash);
                              break;
                            default:
                          }
                        });
                      },
                      child: Icon(
                        Icons.settings,
                        color: CustomColors.witheColor,
                        size: Get.width * 0.08,
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
      Center(
        child: Padding(
          padding: EdgeInsets.only(top: Get.height * 0.04),
          child: Container(
            height: Get.height * 0.1,
            decoration: BoxDecoration(
              color: CustomColors.witheColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 30,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SvgPicture.asset(
              'assets/images/logo.svg',
              width: Get.width * 0.07,
              height: Get.height * 0.07,
            ),
          ),
        ),
      ),
    ],
  );
}
