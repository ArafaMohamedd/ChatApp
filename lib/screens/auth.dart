//import 'dart:math';
import 'dart:developer';
import 'dart:io' as io;
//import 'package:firebase_core/firebase_core.dart';
import 'package:chatnew/widgets/user_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _entteredEmail = '';
  var _entteredUsername = '';
  var _enteredPassword = '';
  io.File? _selectedImage;
  var _isUploading = false;

  void _submit() async{
    final valid = _formKey.currentState!.validate();

    if (!valid || (!_isLogin && _selectedImage == null)) {
      return;
    }



    try{
      setState(() {
          _isUploading = true;
      });

      if (_isLogin) {
        final UserCredential userCredential =
        await  _firebase.signInWithEmailAndPassword(
          email: _entteredEmail,
          password: _enteredPassword,
        );

      }else{
        final UserCredential userCredential =
        await  _firebase.createUserWithEmailAndPassword(
          email: _entteredEmail,
          password: _enteredPassword,
        );
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredential.user!.uid}.jpg');

          await storageRef.putFile(_selectedImage!);
          final imageUrl = await storageRef.getDownloadURL();
          log(imageUrl);

         await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
                  'username': _entteredUsername ,
                  'email': _entteredEmail,
                  'image_url': imageUrl,
          });

      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Authentucation failed.'),
        ),
      );
        setState(() {
          _isUploading = false;
        });
    }


    _formKey.currentState!.save();
    log(_entteredEmail);
    log(_enteredPassword);

  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 30,
                  right: 20,
                  left: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                           if (!_isLogin)   UserImagepicker(onPickImage: (io.File pickedImage) {
                             _selectedImage = pickedImage;
                           },),
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Email Adrress'
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                onSaved: (value) => _entteredEmail = value!,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty || !value.contains('a')){
                                    return 'Please enter a valid email address.';
                                  }
                                  return null;
                                },
                              ),

                              if (!_isLogin)
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Username'
                                ),
                                onSaved: (value) => _entteredUsername = value!,
                                validator: (value) {
                                  if (value == null || value.trim().length < 4 ){
                                    return 'Please enter at least 4 characters.';
                                  }
                                  return null;
                                },
                              ),

                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'password'
                                ),
                                obscureText: true,
                                onSaved: (value) => _enteredPassword = value!,
                                validator: (value) {
                                  if (value == null || value.trim().length < 6){
                                    return 'Password must be at least 6 characters long.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12,),
                              if(_isUploading) const CircularProgressIndicator(),
                              if(!_isUploading)
                              ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                ),
                                child: Text(_isLogin ? 'Login' : 'Signup'),
                              ),
                               if(!_isUploading)
                              TextButton(
                                onPressed: (){
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },

                                child: Text(
                                  _isLogin
                                      ? 'Create an account'
                                      : 'I already have an account',
                                ),
                              )
                            ],
                          )
                      ),
                    )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}