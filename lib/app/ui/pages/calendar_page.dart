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
      padding: const EdgeInsets.only(top: 8.0),
      child: Calendar(
        startOnMonday: true,
        weekDays: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'],
        eventsList: controller.eventList,
        isExpandable: true,
        eventDoneColor: Colors.green,
        selectedColor: Colors.pink,
        selectedTodayColor: Colors.red,
        todayColor: Colors.blue,
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
