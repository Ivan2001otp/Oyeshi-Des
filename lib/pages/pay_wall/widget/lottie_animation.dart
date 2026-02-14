import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieAnimationWidget extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;

  const LottieAnimationWidget({
    super.key,
    required this.assetPath,
    this.width = 200,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Lottie.asset(
        assetPath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        repeat: true,
        animate: true,
      ),
    );
  }
}
