import 'package:chatnew/core/utils/constants.dart';
import 'package:chatnew/core/utils/cashe_helper.dart';
import 'package:chatnew/core/utils/navigateAndFinish.dart';
import 'package:chatnew/modules/social_app/forgetPassword/forgetPassword_screen.dart';
import 'package:chatnew/modules/social_app/social_login/cubit/cubit.dart';
import 'package:chatnew/modules/social_app/social_login/cubit/states.dart';
import 'package:chatnew/modules/social_app/social_login/toast.dart';
import 'package:chatnew/modules/social_app/social_register/social_register_screen.dart';
import 'package:chatnew/layout/social_layout.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/utils/constants.dart';

class SocialLoginScreen extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => SocialLoginCubit(),
      child: BlocConsumer<SocialLoginCubit, SocialLoginStates>(
        listener: (context, state) {
          if(state is SocialLoginErrorState)
            {

              showToast(
                  text: state.error,
                  state: ToastStates.ERROR
              );
            }
          if(state is SocialLoginSuccessState){
            print('Login success state received with uId: ${state.uId}');
            CasheHelper.saveData(
              key: 'uId',
              value: state.uId,
            ).then((value) {
              print('uId saved to cache: ${state.uId}');
              uId = state.uId;
              print('Global uId updated: $uId');

              navigateAndFinish(
                context,
                SocialLayout(),
              );
            });
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: <Widget>[
                        Center(
                          child: Text(
                            'Login',
                            style: Theme.of(context).textTheme.headline4?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 38,
                            ),
                          ),
                        ),
                        SizedBox(height: 30.0),
                        Image.asset(
                          'assets/images/chatify.png',
                        ),
                        SizedBox(height: 30.0),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email_outlined),
                            labelText: 'Email Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(SocialLoginCubit.get(context).suffix),
                              onPressed: () {
                                SocialLoginCubit.get(context).changePasswordVisibility();
                              },
                            ),
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          onFieldSubmitted: (value) {
                            if (formKey.currentState?.validate() ?? false) {
                               SocialLoginCubit.get(context).userLogin(
                                 email: emailController.text,
                                 password: passwordController.text,
                               );
                            }
                          },
                          obscureText: SocialLoginCubit.get(context).isPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ForgetPasswordScreen()),
                              );
                            },
                            child: Text('Forget Password?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: KMainColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        ConditionalBuilder(
                          condition: state is! SocialLoginLoadingState,
                          builder: (context) => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KMainColor,
                              minimumSize: Size(double.infinity, 50),
                            ),
                            onPressed: () {
                              if (formKey.currentState?.validate() ?? false) {
                                 SocialLoginCubit.get(context).userLogin(
                                   email: emailController.text,
                                    password: passwordController.text,
                                 );
                              }
                            },
                            child: Text(
                                'Continue',style: TextStyle(
                              color: Colors.white,
                            ),
                            ),
                          ),
                          fallback: (context) => Center(child: CircularProgressIndicator()),
                        ),
                        SizedBox(height: 15.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Don\'t have an account?', style: TextStyle(fontWeight: FontWeight.bold),),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SocialRegisterScreen(),
                                  ),
                                );
                              },
                              child: Text('Register', style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: KMainColor,

                              ),),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

