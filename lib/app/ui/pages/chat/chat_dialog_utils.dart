import 'dart:math' as math;

import 'package:flutter/material.dart';

double dialogContentHeight(
  BuildContext context, {
  required double maxFraction,
}) {
  final mediaQuery = MediaQuery.of(context);
  final safeHeight =
      mediaQuery.size.height -
      mediaQuery.viewInsets.bottom -
      mediaQuery.padding.vertical;
  final preferredHeight = safeHeight * maxFraction;
  final maxContentHeight = math.max(120.0, safeHeight - 180.0);

  return math.min(preferredHeight, maxContentHeight);
}
