import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/index.dart';
import '../../data/shared/api_config.dart';
import '../../routes/index.dart';
import '../index.dart';

Widget customAppbar({bool showUserMenu = true}) {
  if (!showUserMenu) {
    return const _BrandHeader();
  }
  return const _AuthenticatedHeader();
}

class _AuthenticatedHeader extends StatefulWidget {
  const _AuthenticatedHeader();

  @override
  State<_AuthenticatedHeader> createState() => _AuthenticatedHeaderState();
}

class _AuthenticatedHeaderState extends State<_AuthenticatedHeader> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final globalController = GlobalController.to;
    final customMenuController = CustomMenuController.to;
    return Container(
      height: 66,
      color: CustomColors.primaryDarkerColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Obx(() {
        final employee = globalController.authenticatedEmployee.value;
        final doctorName = employee?.shortName.trim().isNotEmpty == true
            ? employee!.shortName.trim()
            : employee?.name.trim() ?? 'Médico';
        final location = globalController.selectedStoreName.value.trim();
        return Row(
          children: [
            Builder(
              builder: (context) => IconButton(
                tooltip: 'Menu',
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu, color: Colors.white),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_greeting()}, $doctorName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: CustomColors.primaryColor,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location.isNotEmpty ? location : 'Local',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: CustomColors.primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Chat',
              onPressed: () {
                customMenuController.selectedPosItem.value = -1;
                if (Get.isRegistered<ChatController>()) {
                  ChatController.to.openPendingConversationOrChat();
                  return;
                }
                Get.toNamed(Routes.chat);
              },
              icon: _HeaderIconWithBadge(
                icon: Icons.chat_outlined,
                count: globalController.pendingConversations.value,
                iconSize: 22,
              ),
            ),
            if (globalController.canAccessAlarms)
              IconButton(
                tooltip: 'Alarmes',
                onPressed: () {
                  customMenuController.selectedPosItem.value = -1;
                  Get.toNamed(Routes.alarm);
                },
                icon: _HeaderIconWithBadge(
                  icon: Icons.notifications_none,
                  count: globalController.pendingAlarms.value,
                  iconSize: 24,
                ),
              ),
          ],
        );
      }),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Bom dia';
    if (hour >= 12 && hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }
}

class _HeaderIconWithBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  final double iconSize;

  const _HeaderIconWithBadge({
    required this.icon,
    required this.count,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, color: Colors.white, size: iconSize),
        if (count > 0)
          Positioned(
            top: -8,
            right: -10,
            child: Container(
              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
              padding: const EdgeInsets.symmetric(horizontal: 3),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: CustomColors.primaryDarkerColor,
      child: Row(
        children: [
          SvgPicture.asset('assets/images/logo.svg', height: 34),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Biogest Clinic',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            ApiConfig.activeApiName,
            style: const TextStyle(color: Color(0xff9EDDD7), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
