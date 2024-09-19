//import 'dart:html';
//import 'dart:io';
import 'dart:io' as io;  // Alias dart:io
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
  
class UserImagepicker extends StatefulWidget {
  const UserImagepicker({Key? key, required this.onPickImage}) : super(key: key);

  final void Function(io.File pickedImage) onPickImage;

  @override
  State<UserImagepicker> createState() => _UserImagepickerState();
}

class _UserImagepickerState extends State<UserImagepicker> {

  io.File? _pickedImageFile;

  void _pickImage() async{
 final XFile? pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 150,
      imageQuality: 50,
    );

  if (pickedImage == null) {
    return;
  }

 if (!kIsWeb) {
   setState(() {
     _pickedImageFile = io.File(pickedImage.path);
   });
 }


   widget.onPickImage(_pickedImageFile!);

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
          _pickedImageFile == null ? null : FileImage(_pickedImageFile!),
        ),
        TextButton.icon(
            onPressed: _pickImage,
            icon: Icon(Icons.image),
            label: Text(
                'Add Image',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),

        )
      ],
    );
  }
}

