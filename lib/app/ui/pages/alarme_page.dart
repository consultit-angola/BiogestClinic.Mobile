import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../controllers/index.dart';
import '../index.dart';

class AlarmePage extends GetView<AlarmeController> {
  const AlarmePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AlarmeController>(
      builder: (alarmeController) => Scaffold(
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
                    Expanded(child: notificationList()),
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

  Widget notificationList() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        search(),
        NotificationItem(
          date: '10/10/2025',
          title: 'Lote MRET 1 caducado',
          subtitle: 'O lote MRET 1 caducou no dia 10/10/2025, favor verificar.',
        ),
        NotificationItem(
          date: '09/10/2025',
          title: 'Consulta cancelada',
          subtitle:
              'A consulta agendada para o dia 12/10/2025 foi cancelada pelo cliente.',
        ),
        NotificationItem(
          date: '10/10/2025',
          title: 'Produto para encomenda chegou',
          subtitle: 'O produto solicitado para encomenda chegou ao estoque.',
        ),
      ],
    );
  }

  Widget search() {
    return Padding(
      padding: EdgeInsets.all(Get.width * 0.05),
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
          decoration: InputDecoration(
            hintText: 'Pesquisar notificações',
            prefixIcon: const Icon(Icons.search),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onChanged: (value) {},
        ),
      ),
    );
  }
}

class NotificationItem extends StatefulWidget {
  final String date;
  final String title;
  final String subtitle;

  const NotificationItem({
    super.key,
    required this.date,
    required this.title,
    required this.subtitle,
  });

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleExpanded,
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
              children: [
                Text(
                  widget.date,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CustomColors.witheColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      color: CustomColors.witheColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ExpandIcon(
                  onPressed: (value) => toggleExpanded(),
                  color: CustomColors.witheColor,
                  isExpanded: expanded,
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: EdgeInsets.only(top: Get.height * 0.015),
                child: Text(
                  widget.subtitle,
                  style: TextStyle(
                    color: CustomColors.witheColor.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  void toggleExpanded() {
    setState(() {
      expanded = !expanded;
    });
  }
}
