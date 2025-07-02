import 'dart:io';

import 'package:chatnew/core/utils/components.dart';
import 'package:chatnew/core/utils/constants.dart';
import 'package:chatnew/layout/cubit/cubit.dart';
import 'package:chatnew/layout/cubit/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class EditProfileScreen extends StatelessWidget {
  var nameController = TextEditingController();
  var bioController = TextEditingController();
  var phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var userModel = SocialCubit.get(context).userModel;
        var profileImage = SocialCubit.get(context).profileImage;
        var coverImage = SocialCubit.get(context).coverImage;

        nameController.text = userModel?.name ?? '';
        bioController.text = userModel?.bio ?? '';
        phoneController.text = userModel?.phone ?? '';

        return Scaffold(
          appBar: defaultAppBar(
            context: context,
            title: 'Edit profile',
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  if(state is SocialUserUpdateLoadingState)
                    LinearProgressIndicator(),
                 // if(state is SocialUserUpdateLoadingState)
                  Container(
                    height: 190,
                    child: Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.topCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Profile",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Your profile information",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          child: Stack(
                            alignment: AlignmentDirectional.bottomEnd,
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                radius: 64.0,
                                child: CircleAvatar(
                                  radius: 60.0,
                                  backgroundImage: profileImage != null
                                      ? FileImage(profileImage)
                                      : (userModel?.image != null && userModel!.image!.isNotEmpty
                                          ? NetworkImage(userModel.image!)
                                          : const AssetImage('assets/images/default_profile.png')) as ImageProvider,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  SocialCubit.get(context).getProfileImage();
                                },
                                icon: CircleAvatar(
                                  backgroundColor: KMainColor,
                                  radius: 20,
                                  child: Icon(
                                    Icons.camera_enhance_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5.0),
                  defaultFormField(
                    controller: nameController,
                    type: TextInputType.name,
                    validte: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'name must not be empty';
                      }
                      return null;
                    },
                    label: 'Full Name',
                    prefix: Icons.supervised_user_circle,
                  ),


                  SizedBox(height: 10.0),

                  defaultFormField(
                    controller: bioController,
                    type: TextInputType.text,
                    validte: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'About must not be empty';
                      }
                      return null;
                    },
                    label: 'About',
                    prefix: Icons.info_outline_rounded,
                  ),

                  SizedBox(height: 10.0),

                  defaultFormField(
                    controller: phoneController,
                    type: TextInputType.text,
                    validte: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'phone number must not be empty';
                      }
                      return null;
                    },
                    label: 'phone',
                    prefix: Icons.call,
                  ),
                  SizedBox(height: 30,),
                  ElevatedButton(
        onPressed: () {
          SocialCubit.get(context).uploadProfileImageAndUpdateUser(
            name: nameController.text,
            phone: phoneController.text,
            bio: bioController.text,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: KMainColor, // Deep purple (adjust if needed)
          foregroundColor: Colors.white,      // Text color
          padding: EdgeInsets.symmetric(horizontal: 100, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Fully rounded
          ),
          textStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        child: Text('Save changes'),
      ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}