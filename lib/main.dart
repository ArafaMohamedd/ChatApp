import 'package:chatnew/core/utils/blocObserrver.dart';
import 'package:chatnew/core/utils/cashe_helper.dart';
import 'package:chatnew/core/utils/constants.dart';
import 'package:chatnew/core/utils/widgets/cubit/cubit.dart';
import 'package:chatnew/core/utils/widgets/cubit/states.dart';
import 'package:chatnew/features/on%20Boarding/presentation/on_boarding_view.dart';
import 'package:chatnew/layout/cubit/cubit.dart';
import 'package:chatnew/layout/social_layout.dart';
import 'package:chatnew/modules/social_app/setting_1/setting_screen1.dart';
import 'package:chatnew/modules/social_app/settings_2/setting_screens2.dart';
import 'package:chatnew/modules/social_app/social_register/social_register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'modules/social_app/social_login/social_login_screen.dart';
import 'modules/social_app/setting_1/online_screen.dart';
import 'modules/social_app/setting_1/about_screen.dart';
import 'modules/social_app/setting_1/profile_photo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = MyBlocObserver();
  await CasheHelper.init();
  
  // Initialize Firebase with proper error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    
    if (!e.toString().contains('A Firebase App named "[DEFAULT]" already exists')) {
      rethrow;
    }
  }
  
  await FirebaseAuth.instance.setLanguageCode('en');

  uId = CasheHelper.getData(key: 'uId');
  print('Stored uId: $uId'); // Debug print

  Widget widget;

  if (uId != null && uId!.isNotEmpty) {
    widget = SocialLayout();
    print('Starting with SocialLayout for user: $uId'); // Debug print
  } else {
    widget = OnBoardingView();
    print('Starting with OnBoardingView - no user logged in'); // Debug print
  }

  runApp(MyApp(startWidget: OnBoardingView()));
}

class MyApp extends StatelessWidget {
  final Widget startWidget;

  const MyApp({super.key, required this.startWidget});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => AppCubit()),
        BlocProvider(create: (BuildContext context) {
          final cubit = SocialCubit();
          if (uId != null && uId!.isNotEmpty) {
            cubit.getUserData();
            cubit.getUsers();
          }
          return cubit;
        }),
      ],
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return MaterialApp(
            theme: ThemeData(fontFamily: 'Poppins'),
            debugShowCheckedModeBanner: false,
            home: startWidget,
            routes: {
              '/online': (context) => OnlineScreen(),
              '/about': (context) => AboutScreen(),
              '/profile_photo': (context) => ProfilePhotoScreen(),
            },
          );
        },
      ),
    );
  }
}