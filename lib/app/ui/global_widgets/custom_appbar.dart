import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../index.dart';

Widget customAppbar() {
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
          padding: EdgeInsetsGeometry.only(
            top: Get.height * 0.025,
            left: Get.width * 0.12,
          ),
          child: Text(
            'myBio',
            style: Get.textTheme.headlineMedium!.copyWith(
              color: CustomColors.witheColor,
              fontWeight: FontWeight.bold,
            ),
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
