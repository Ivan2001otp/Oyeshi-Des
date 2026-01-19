import 'package:flutter/material.dart';

class NoGlowScrollBehaviour extends ScrollBehavior {
  const NoGlowScrollBehaviour();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

 
 @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}