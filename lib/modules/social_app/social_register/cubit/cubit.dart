import 'package:chatnew/models/social_app/social_user_model.dart';
import 'package:chatnew/modules/social_app/social_register/cubit/states.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SocialRegisterCubit extends Cubit<SocialRegisterStates> {
  SocialRegisterCubit() : super(SocialRegisterInitialState());

  static SocialRegisterCubit get(context) => BlocProvider.of(context);

  void userRegister({
  required String name,
  required String email,
  required String password,
  required String phone,
}) {
      print('hello');
     emit(SocialRegisterLoadingState());


    FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password
    ).then((value) {
      print(value.user!.email);
      print(value.user!.uid);
      userCreate(
          uId: value.user!.uid,
          phone: phone,
          email: email,
          name: name,

      );
     // emit(SocialRegisterSuccessState());
    }).catchError((error){
      emit(SocialRegisterErrorState(error.toString()));
    });
  }

  void userCreate({
    required String name,
    required String email,
    required String phone,
    required String uId,
})

  {
    SocialUserModel model = SocialUserModel(
      name: name,
      email: email,
      phone: phone,
      uId: uId,
      bio: 'Write your bio...',
      cover: 'https://img.freepik.com/premium-vector/vector-ramadan-kareem-lantern-hanging-chains-composition_694085-192.jpg?w=1380',
      image: 'https://m.media-amazon.com/images/I/51q4sgCtasL.jpg',
      isEmailVerified: false,
    );



    FirebaseFirestore
        .instance
        .collection('users')
        .doc(uId)
        .set(model
        .toMap())
        .then((value)
    {
          emit(SocialCreateUserSuccessState());
    })
        .catchError((error)
    {
      emit(SocialCreateUserErrorState(error.toString()));
    });

  }


  IconData suffix = Icons.visibility_outlined;
  bool isPassword = true;

  IconData confirmSuffix = Icons.visibility_outlined;
  bool isConfirmPassword = true;

  void changePasswordVisibility() {
    isPassword = !isPassword;
    suffix = isPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined;
    emit(SocialRegisterChangePasswordVisibilityState());
  }

  void changeConfirmPasswordVisibility() {
    isConfirmPassword = !isConfirmPassword;
    confirmSuffix = isConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined;
    emit(SocialRegisterChangePasswordVisibilityState());
  }
}