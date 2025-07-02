import 'package:chatnew/core/utils/constants.dart';
import 'package:chatnew/core/utils/navigateAndFinish.dart';
import 'package:chatnew/modules/social_app/social_register/cubit/cubit.dart';
import 'package:chatnew/modules/social_app/social_register/cubit/states.dart';
import 'package:chatnew/layout/social_layout.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SocialRegisterScreen extends StatelessWidget {
  var formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var phoneController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => SocialRegisterCubit(),
      child: BlocConsumer<SocialRegisterCubit, SocialRegisterStates>(
        listener: (context, state) {
          if (state is SocialCreateUserSuccessState) {
            navigateAndFinish(context, SocialLayout());
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
                        Text(
                          'REGISTER',
                          style: Theme.of(context).textTheme.headline4?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 35
                          ),
                        ),
                        SizedBox(height: 20),
                        Image.asset(
                          'assets/images/chatify.png',
                        ),
                        SizedBox(height: 30),
                        // Name Field
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            prefix: Icon(Icons.person),
                            labelText: 'User Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10.0),
                        // Email Field
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            prefix: Icon(Icons.email_outlined),
                            labelText: 'ُEnter Your Email Address',
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
                        SizedBox(height: 10.0),
                        // Phone Field
                        TextFormField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            prefix: Icon(Icons.phone),
                            labelText: 'Enter your Phone',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                       
                        SizedBox(height: 10.0),
                        
                         // Password Field
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(SocialRegisterCubit.get(context).suffix),
                              onPressed: () {
                                SocialRegisterCubit.get(context).changePasswordVisibility();
                              },
                            ),
                            labelText: 'Enter YourPassword',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          onFieldSubmitted: (value) {
                            if (formKey.currentState?.validate() ?? false) {
                              // Handle form submission
                            }
                          },
                          obscureText: SocialRegisterCubit.get(context).isPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        
                        SizedBox(height: 16.0),
                        // Register Button
                        ConditionalBuilder(
                          condition: state is! SocialRegisterLoadingState,
                          builder: (context) => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KMainColor,
                              minimumSize: Size(double.infinity, 50),
                            ),
                            onPressed: () {
                              if (formKey.currentState?.validate() ?? false) {
                                SocialRegisterCubit.get(context).userRegister(
                                  name: nameController.text,
                                  email: emailController.text,
                                  password: passwordController.text,
                                  phone: phoneController.text,
                                );
                              }
                            },
                            child: Text(
                              'Register',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          fallback: (context) => Center(child: CircularProgressIndicator()),
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