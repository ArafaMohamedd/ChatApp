import 'package:flutter/material.dart';

void navigateAndFinish(BuildContext context, Widget screen) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => screen),
        (Route<dynamic> route) => false, // Remove all previous routes
  );
}



