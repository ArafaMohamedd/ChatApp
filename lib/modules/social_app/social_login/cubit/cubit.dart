import 'package:chatnew/modules/social_app/social_login/cubit/states.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SocialLoginCubit extends Cubit<SocialLoginStates> {
  SocialLoginCubit() : super(SocialLoginInitialState());

  static SocialLoginCubit get(context) => BlocProvider.of(context);

  IconData suffix = Icons.visibility_outlined;
  bool isPassword = true;

   void userLogin({
    required String email,
    required String password,
  }) {
    print('Login attempt for email: $email');
    emit(SocialLoginLoadingState());

    FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password
    ).then((value) => {
      print('Firebase Auth successful for email: ${value.user!.email}'),
      print('Firebase Auth UID: ${value.user!.uid}'),
      emit(SocialLoginSuccessState(value.user!.uid)),
    }).catchError((error) {
      print('Firebase Auth error: $error');
      emit(SocialLoginErrorState(error.toString()));
    });

  }

  void changePasswordVisibility() {
    isPassword = !isPassword;
    suffix = isPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined;

    emit(SocialChangePasswordVisibilityState());
  }
}