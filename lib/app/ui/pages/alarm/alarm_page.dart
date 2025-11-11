import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../controllers/index.dart';
import '../../index.dart';

class AlarmPage extends GetView<AlarmController> {
  const AlarmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AlarmController>(
      builder: (alarmController) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              customAppbar(),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Obx(
                        () => Column(
                          children: [
                            search(),
                            Expanded(child: alarmInstancesList()),
                          ],
                        ),
                      ),
                    ),
                    customMenu(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget search() {
    var filterItems = controller.globalController.programmedAlarmsMap.entries
        .map(
          (entry) => PopupMenuItem<int>(
            value: entry.key,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                controller.filterAlarmID.value == entry.key
                    ? const Expanded(flex: 2, child: Icon(Icons.check))
                    : const Spacer(flex: 2),
                Expanded(
                  flex: 8,
                  child: Text(
                    '${entry.value['alarm']?.name ?? 'Indefinido'} (${entry.value['length']})',
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: CustomColors.witheColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                cursorColor: CustomColors.primaryColor,
                decoration: InputDecoration(
                  hintText: 'Pesquisar notificações',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: GestureDetector(
                    onTapDown: (TapDownDetails details) {
                      showMenu(
                        context: Get.context!,
                        position: RelativeRect.fromLTRB(
                          details.globalPosition.dx,
                          details.globalPosition.dy,
                          0,
                          0,
                        ),
                        items: filterItems,
                      ).then((value) {
                        if (value != null) {
                          controller.filterAlarmID.value = value;
                        }
                      });
                    },
                    child: Icon(Icons.filter_list, size: Get.width * 0.08),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (value) => controller.searchQuery.value = value,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(
                () => Text(
                  'Total ${controller.filteredInstances.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget alarmInstancesList() {
    return Obx(() {
      final widgetList = controller.filteredInstances.map((a) {
        return alarmDetails(
          alarmId: a.id!,
          date: formatDate(a.date),
          title: controller
              .globalController
              .programmedAlarmsMap[a.alarmId]?['alarm']
              ?.name,
          subtitle: a.entityStringId,
        );
      }).toList();

      return Padding(
        padding: EdgeInsets.only(bottom: Get.height * 0.02),
        child: ListView(
          padding: EdgeInsets.zero,
          children: widgetList.isNotEmpty
              ? widgetList
              : [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Nenhuma notificação encontrada'),
                    ),
                  ),
                ],
        ),
      );
    });
  }

  Widget alarmDetails({
    required int alarmId,
    String? date,
    String? title,
    String? subtitle,
  }) {
    final isExpanded = controller.isExpanded(alarmId);

    return GestureDetector(
      onTap: () => controller.toggleExpanded(alarmId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: Get.width * 0.9,
        margin: EdgeInsets.symmetric(
          horizontal: Get.width * 0.05,
          vertical: Get.height * 0.01,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: Get.width * 0.04,
          vertical: Get.height * 0.015,
        ),
        decoration: BoxDecoration(
          color: CustomColors.secondaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date ?? 'Sem data',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: CustomColors.witheColor,
                        ),
                      ),
                      Text(
                        title ?? 'Sem nome',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: TextStyle(
                          color: CustomColors.witheColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                ExpandIcon(
                  onPressed: (_) => controller.toggleExpanded(alarmId),
                  color: CustomColors.witheColor,
                  isExpanded: isExpanded,
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: EdgeInsets.only(top: Get.height * 0.015),
                child: Text(
                  subtitle ?? 'Sem descrição',
                  style: TextStyle(
                    color: CustomColors.witheColor.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}
