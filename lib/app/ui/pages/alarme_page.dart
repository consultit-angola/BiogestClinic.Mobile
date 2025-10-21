import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../controllers/index.dart';
import '../../routes/index.dart';
import '../index.dart';

class AlarmePage extends GetView<AlarmeController> {
  const AlarmePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AlarmeController>(
      builder: (chatController) => Scaffold(
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
                Column(children: [customAppbar(), notificationList()]),
                customMenu(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget notificationList() {
    return Expanded(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          contact(
            title: 'Maria Silva',
            subtitle: 'Ola como posso ajudar?',
            time: '10:30 AM',
            userID: 1,
          ),
          contact(
            title: 'João Pereira',
            subtitle:
                'Preciso marcar uma consulta esto es para aumentar el tamano del texto y ver como se comporta en la interfaz de usuario.',
            time: 'Ontem',
            userID: 2,
          ),
        ],
      ),
    );
  }

  Widget contact({
    required String title,
    required String subtitle,
    required String time,
    required int userID,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: Get.width * 0.066,
        backgroundColor: Colors.black12,
        child: CircleAvatar(
          radius: Get.width * 0.06,
          backgroundColor: CustomColors.secondaryColor,
          child: Icon(
            Icons.person_rounded,
            size: Get.width * 0.1,
            color: CustomColors.witheColor,
          ),
        ),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
      onTap: () {
        Get.toNamed(Routes.chatDetails, arguments: {'userID': userID});
      },
      trailing: Text(time),
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
            hintText: 'Pesquisar contatos',
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
