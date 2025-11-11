import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../controllers/index.dart';
import '../../index.dart';

class UserPage extends GetView<UserController> {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(
      builder: (userController) => Scaffold(
        resizeToAvoidBottomInset: false,
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
            customMenu(),
            tableUserInfo(),
          ],
        ),
      ),
    );
  }

  Widget tableUserInfo() {
    final userMap = controller.globalController.authenticatedUser.value!
        .toJson();
    final rows = userMap.entries.map((entry) {
      return DataRow(
        cells: [
          DataCell(Text(entry.key)),
          DataCell(Text(entry.value.toString())),
        ],
      );
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        top: Get.height * 0.15,
        left: Get.width * 0.05,
        right: Get.width * 0.05,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DataTable(
              columns: [
                DataColumn(
                  label: Text(
                    "Propriedade",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Descrição",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: rows,
            ),
          ],
        ),
      ),
    );
  }
}
