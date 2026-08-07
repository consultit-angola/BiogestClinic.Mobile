import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'package:get/get.dart';

import '../../../controllers/index.dart';
import '../../index.dart';

class ActivitiesPage extends GetView<ActivitiesController> {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.backgroundColor,
      drawer: customDrawer(),
      body: Column(
        children: [
          customAppbar(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => RefreshIndicator(
                onRefresh: () => controller.loadActivities(),
                child: ListView(
                  primary: false,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: constraints.maxHeight,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              Get.width * 0.04,
                              12,
                              Get.width * 0.04,
                              8,
                            ),
                            child: const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Actividades',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Expanded(child: Obx(_calendar)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: customMenu(alignBottom: false),
    );
  }

  Widget _calendar() {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Get.width * 0.03),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: Get.width * 0.02),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CustomColors.borderColor),
            ),
            child: Calendar(
              topRowIconColor: CustomColors.primaryDarkerColor,
              bottomBarColor: CustomColors.primaryLightColor,
              startOnMonday: true,
              weekDays: const ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'],
              eventsList: controller.eventList.toList(),
              isExpandable: true,
              eventDoneColor: CustomColors.primaryDarkerColor,
              selectedColor: CustomColors.tertiaryColor,
              selectedTodayColor: Colors.red,
              todayColor: CustomColors.primaryColor,
              eventColor: CustomColors.primaryDarkerColor,
              locale: 'pt_PT',
              todayButtonText: 'Hoje',
              allDayEventText: 'O dia todo',
              multiDayEndText: 'Fim',
              isExpanded: true,
              expandableDateFormat: 'EEEE, dd. MMMM yyyy',
              datePickerType: DatePickerType.date,
              onPrintLog: (_) {},
              dayOfWeekStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
              onMonthChanged: controller.onMonthChanged,
              eventCellBuilder: _activityEvent,
              eventTileHeight: 92,
            ),
          ),
        ),
        if (controller.isLoading.value)
          Positioned.fill(
            child: AbsorbPointer(
              child: ColoredBox(
                color: Colors.white70,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
      ],
    );
  }

  Widget _activityEvent(
    BuildContext context,
    NeatCleanCalendarEvent event,
    String start,
    String end,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: CustomColors.primaryDarkerColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.summary,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (event.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$start\n$end',
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
