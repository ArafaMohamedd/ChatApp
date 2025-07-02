import 'package:chatnew/core/utils/constants.dart';
import 'package:chatnew/core/utils/size_config.dart';
import 'package:flutter/material.dart';

class CustomGeneralButton extends StatelessWidget {
  const CustomGeneralButton({super.key, this.text, this.onTap});

  final String? text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        width: SizeConfig.screenWidth,
        decoration: BoxDecoration(
          color: KMainColor,
          borderRadius: BorderRadius.circular(28)
          ),
        child: Center(
          child: Text(
            text!,
            style: TextStyle(
                   fontSize: 14,
                   color: Color(0xffFFFFFF),
                  ),
                  textAlign: TextAlign.right,
            )
          ),
      ),
    );
  }
}