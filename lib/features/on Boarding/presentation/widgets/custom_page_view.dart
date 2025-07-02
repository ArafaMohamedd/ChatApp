import 'package:chatnew/features/on%20Boarding/presentation/widgets/page_view_item.dart';
import 'package:flutter/material.dart';

class CustomPageView extends StatelessWidget {
  const CustomPageView({super.key, required this.pageController});
  final   PageController? pageController;

  @override
  Widget build(BuildContext context) {
    return  PageView(
      controller: pageController,
      children: const [
        PageViewItem(
         image: 'assets/images/on1.png',
          title: 'Welcome to [App Name]! We\'re \n excited'
              ' to have you. Let\'s get you set\n up in just a few steps.',
        ),
        PageViewItem(
          image: 'assets/images/on2.png',
          title: 'Here\'s how to start a chat.',
        ),
        PageViewItem(
          image: 'assets/images/on3.png',
          title: ' Add contacts easily by clicking here.',
        ),
      ],
    );
  }
}