import 'package:chatnew/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class ForgetPasswordScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 70),
                Image.asset('assets/images/chatify.png'),
                const SizedBox(height: 40),
                const Text(
                  'Forget Password ?',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Enter your Email or Phone Number',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: KMainColor,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email or phone number';
                    }
                    if (value.contains('@') && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return null; // We'll handle this case in the button press
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Email/Phone',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    prefixIcon: const Icon(Icons.email),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      // Additional validation for incomplete email
                      if (emailController.text.contains('@') &&
                          !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text)) {
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.warning,
                          text: 'You just broke protocol',
                        );
                        return;
                      }

                      // Valid input - proceed with password reset
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reset link sent')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: KMainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Send',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}