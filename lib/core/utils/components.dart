import 'package:chatnew/core/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget defaultButton({
   double width = double.infinity,
   Color background = KMainColor,
   bool isUpperCase = true,
  double radius = 0.0,
   required void Function() function,
   required String text,
}) => Container(
  width: width,
  height: 40,
  child: MaterialButton(
    onPressed: function,
    child: Text(
      isUpperCase ? text.toUpperCase() : text,
      style: TextStyle(color: Colors.white),
    ),

  ),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    color: background,
  ),
);



Widget defaultTextButton({
  required void Function() function,
  required String text,
}) =>
    TextButton(
        onPressed: function,
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: KMainColor,
          ),
        ),
    );


Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  required String? Function(String?) validte,
  required String label,
  required IconData prefix,
  IconData? suffix,
  void Function(String)? onSubmit,
  void Function(String)? onChange,
}) => TextFormField(
  controller: controller,
  keyboardType: type,
  onFieldSubmitted: onSubmit,
  validator: validte,
  decoration: InputDecoration(
    labelText: label,
    prefixIcon: Icon(prefix,),
    suffixIcon: suffix != null? Icon(suffix, color: KMainColor,) : null,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: KMainColor)
    ),
    prefixIconColor: MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.focused)) {
          return KMainColor; // Blue icon when focused
        }
        return Colors.grey; // Default icon color
      },

),
  )
);


PreferredSizeWidget defaultAppBar({
  required BuildContext context,
  String? title,
  List<Widget>? actions,
}) => AppBar(
  leading: IconButton(
    onPressed: (){
      Navigator.pop(context);
    },
    icon: Icon(Icons.arrow_back_ios_sharp),
  ),
  titleSpacing: 0.0,
  title: Text(title ?? ''),
  actions: actions,
);


Widget mydivider() => Padding(
    padding: EdgeInsetsDirectional.only(start: 20.0),
        child: Container(
          width: double.infinity,
          height: 1.0,
          color: Colors.grey[300] ,

),

);
