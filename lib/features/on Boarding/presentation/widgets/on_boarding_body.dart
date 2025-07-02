import 'package:chatnew/core/utils/constants.dart';
import 'package:chatnew/features/on%20Boarding/presentation/widgets/custom_indicator.dart';
import 'package:chatnew/modules/social_app/social_login/social_login_screen.dart';
import 'package:chatnew/test.dart';
import 'package:flutter/material.dart';
import 'package:chatnew/core/utils/size_config.dart';
import 'package:chatnew/core/utils/widgets/custom_buttons.dart';
import 'package:chatnew/features/on%20Boarding/presentation/widgets/custom_page_view.dart';
import 'package:dots_indicator/dots_indicator.dart';

class OnBoardingViewBody extends StatefulWidget {
  const OnBoardingViewBody({super.key});

  @override
  State<OnBoardingViewBody> createState() => _OnBoardingViewBodyState();
}

class _OnBoardingViewBodyState extends State<OnBoardingViewBody> {
  PageController? pageController;

  @override
  void initState() {
    pageController = PageController(
      initialPage: 0
    )..addListener(() {
      setState(() {
        
      });
    });
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Column(
        children: [
          // Expanded للصفحة (الصورة + النص + المؤشر)
          Expanded(
            child: CustomPageView(
              pageController: pageController,
            ),
          ),
          // المؤشر
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: CustomIndicator(
              dotIndex: pageController!.hasClients ? pageController!.page ?? 0.0 : 0.0,
            ),
          ),
          // زر Next ثم Skip في الأسفل، Skip على اليمين
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34.0, vertical: 24.0),
            child: Column(
              children: [
                CustomGeneralButton(
                  onTap: () {
                    if (pageController!.page! < 2) {
                      pageController?.nextPage(
                        duration: Duration(milliseconds: 400),
                        curve: Curves.easeIn,
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SocialLoginScreen()),
                      );
                    }
                  },
                  text: pageController!.hasClients ? (pageController?.page == 2 ? 'Get Started' : 'Next') : 'Next',
                ),
                SizedBox(height: 52),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SocialLoginScreen()),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Skip',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff000000),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xff000000),
                            size: 19,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}