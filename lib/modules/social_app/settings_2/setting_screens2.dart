import 'package:chatnew/core/utils/components.dart';
import 'package:chatnew/core/utils/constants.dart';
import 'package:chatnew/core/utils/navigateAndFinish.dart';
import 'package:chatnew/layout/cubit/cubit.dart';
import 'package:chatnew/layout/cubit/states.dart';
import 'package:chatnew/modules/social_app/edit_profile/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class SettingsScreen2 extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state){},
      builder: (context, state)
      {
        var userModel = SocialCubit.get(context).userModel;

        if(state is SocialGetUserErrorState){
          return Center(child: Text('error'),);
        }
        if(state is SocialGetUserLoadingState){
          return CircularProgressIndicator();
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text('Profile'),
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.black,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (userModel?.image != null && userModel!.image!.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  userModel!.image!,
                                  fit: BoxFit.cover,
                                  height: 300,
                                  width: 300,
                                  errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 64,
                          backgroundImage: (userModel?.image != null && userModel!.image!.isNotEmpty)
                              ? NetworkImage(userModel!.image!)
                              : AssetImage('assets/images/icon chat.png') as ImageProvider,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 18),
                  Text(
                    userModel?.name ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                        color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Text(
                    userModel?.bio ?? 'Application Developer Fci',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                      _buildStat('80', 'Image'),
                      _buildStat('10', 'Video'),
                      _buildStat('65', 'Friends'),
                      _buildStat('18', 'Group'),
                    ],
                  ),
                  SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KMainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                      ),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EditProfileScreen()),
                            );
                          },
                          icon: Icon(Icons.edit, size: 20, color: Colors.white),
                          label: Text(
                            'EDIT PROFILE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

