import 'package:flutter/material.dart';

class SkipButton extends StatelessWidget {
  //final VoidCallback onPressed;

  const SkipButton({super.key});

  @override
  Widget build(BuildContext context) {
    return 
 ElevatedButton(
      onPressed: (){},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black, // Customize background color
        foregroundColor: Colors.white, // Customize text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Customize border radius
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Skip'),
          const SizedBox(width: 10), // Adjust spacing between text and icon
          const Icon(Icons.arrow_forward),
        ],
      ),
    );
  }
}

/*

import 'package:flutter/material.dart';

class SocialLoginScreen extends StatelessWidget {
   SocialLoginScreen({Key? key}) : super(key: key);

  var formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'LOGIN',
                    style: Theme.of(context).textTheme.headline4?.copyWith(
                      color: Colors.black
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  textFormfield(

                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

 */