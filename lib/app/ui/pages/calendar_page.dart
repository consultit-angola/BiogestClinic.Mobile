import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';

import '../../controllers/index.dart';
import '../index.dart';

class CalendarPage extends GetView<CalendarController> {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CalendarController>(
      builder: (calendarController) => Scaffold(
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
            Stack(
              children: [
                Column(
                  children: [
                    customAppbar(),
                    Expanded(child: calendar()),
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

  Widget calendar() {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: Get.height * 0.08),
      child: Calendar(
        topRowIconColor: CustomColors.primaryColor,
        bottomBarColor: CustomColors.primaryLightColor,
        startOnMonday: true,
        weekDays: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'],
        eventsList: controller.globalController.eventList..toList(),
        isExpandable: true,
        eventDoneColor: CustomColors.secondaryColor,
        selectedColor: CustomColors.tertiaryColor,
        selectedTodayColor: Colors.red,
        todayColor: CustomColors.primaryColor,
        eventColor: null,
        locale: 'pt_PT',
        todayButtonText: 'Hoje',
        allDayEventText: 'O dia todo',
        multiDayEndText: 'Fim',
        isExpanded: true,
        expandableDateFormat: 'EEEE, dd. MMMM yyyy',
        datePickerType: DatePickerType.date,
        dayOfWeekStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}
