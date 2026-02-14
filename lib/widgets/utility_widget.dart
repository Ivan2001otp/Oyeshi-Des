import 'package:flutter/material.dart';

class UtilityWidgets {
  static Widget DefaultContainerWidget(
      {required Widget child,  bool isMargin = false,  bool isPadding = false, double hM = 16, double vM = 0, double hP = 16, double vP = 0}) {
    return Container(
      margin: isMargin ? const EdgeInsets.symmetric(horizontal: 16.0) : null,
      padding: isPadding ? const EdgeInsets.all(16.0) : null,
      child: child,
    );
  }
}
