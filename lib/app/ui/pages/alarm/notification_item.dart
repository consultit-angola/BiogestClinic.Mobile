import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../index.dart';

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
