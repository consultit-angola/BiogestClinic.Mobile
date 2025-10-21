import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../controllers/index.dart';
import '../index.dart';

class ActivitiesPage extends GetView<ActivitiesController> {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ActivitiesController>(
      builder: (activitiesController) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Image.asset(
              'assets/images/background.png',
              width: Get.width,
              height: Get.height,
              fit: BoxFit.fill,
            ),
            Stack(
              children: [
                Column(
                  children: [
                    customAppbar(),
                    Expanded(child: SizedBox.shrink()),
                  ],
                ),
                customMenu(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
