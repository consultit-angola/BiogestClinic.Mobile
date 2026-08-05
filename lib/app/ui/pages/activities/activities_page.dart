import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../controllers/index.dart';
import '../../index.dart';

class ActivitiesPage extends GetView<ActivitiesController> {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CalendarController>(
      builder: (calendarController) => Scaffold(
        backgroundColor: CustomColors.backgroundColor,
        drawer: customDrawer(),
        body: Column(children: [customAppbar()]),
        bottomNavigationBar: customMenu(alignBottom: false),
      ),
    );
  }
}
