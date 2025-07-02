import 'package:chatnew/core/utils/size_config.dart';
import 'package:flutter/material.dart';

class PageViewItem extends StatelessWidget {
  const PageViewItem({super.key, this.title, this.image});

  final String? title;
  final String? image;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: SizeConfig.defaultSize! * 10,
        ),
        SizedBox(
          child: (image != null && image!.isNotEmpty)
              ? Image.asset(image!)
              : const Placeholder(fallbackHeight: 150),
          ),
        SizedBox(
          height: SizeConfig.defaultSize! * 1,
        ),
        Text(
          title ?? '',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xff000000)
          ),
          textAlign: TextAlign.left,
          ),
      ],
    );
  }
}

