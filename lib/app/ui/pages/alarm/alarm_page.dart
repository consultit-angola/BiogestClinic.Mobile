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
