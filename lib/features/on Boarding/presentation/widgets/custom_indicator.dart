import 'package:chatnew/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';


class CustomIndicator extends StatelessWidget {
  const CustomIndicator({super.key, required this.dotIndex});
  final double? dotIndex;
  @override
  Widget build(BuildContext context) {
    return  DotsIndicator(
                decorator:  DotsDecorator(
                  size: Size.square(9.0),
                  activeSize: const Size(18.0, 9.0),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)
                    ),
                  color:KMainColor,
                  activeColor: KMainColor,
                  ),
                dotsCount: 3,
                position: dotIndex!.toInt(),
              );
  }
}