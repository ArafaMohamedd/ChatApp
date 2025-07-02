import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatnew/layout/cubit/cubit.dart';
import 'package:chatnew/layout/cubit/states.dart';
import 'package:chatnew/core/utils/constants.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:chatnew/modules/social_app/updates status/story_circle.dart';
import 'package:chatnew/modules/story_view_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatesScreen extends StatefulWidget {
  @override
  _StatesScreenState createState() => _StatesScreenState();
}

class _StatesScreenState extends State<StatesScreen> {
  String? _selectedImagePath;
  final TextEditingController _statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Get stories when screen loads
    SocialCubit.get(context).getStories();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {
        if (state is SocialUploadStorySuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _selectedImagePath = null;
            _statusController.clear();
          });
          // Refresh stories list
          SocialCubit.get(context).getStories();
        } else if (state is SocialUploadStoryErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update status'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is SocialUploadTextStatusSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Text status updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _statusController.clear();
          });
          // Refresh stories list
          SocialCubit.get(context).getStories();
        } else if (state is SocialUploadTextStatusErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update text status'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final myStories = SocialCubit.get(context).storiesList[SocialCubit.get(context).userModel?.uId] ?? [];
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search',
                    filled: true,
                    fillColor: Colors.grey[300],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'My Status',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Card(
                  color: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: (SocialCubit.get(context).userModel?.image != null && SocialCubit.get(context).userModel!.image!.isNotEmpty)
                              ? NetworkImage(SocialCubit.get(context).userModel!.image!)
                              : AssetImage('assets/images/icon chat.png') as ImageProvider,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Status',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Tap to add status update',
                                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.camera_alt_outlined, color: Colors.grey[700]),
                          onPressed: () async {
                            showModalBottomSheet(
                              context: context,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (context) => SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.camera_alt),
                                      title: Text('التقاط صورة بالكاميرا'),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        await _pickImage(ImageSource.camera);
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.photo_library),
                                      title: Text('اختيار صورة من المعرض'),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        await _pickImage(ImageSource.gallery);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.grey[700]),
                          onPressed: () async {
                            await _showTextStatusDialog();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (myStories.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        StoryCircle(
                          imageUrl: SocialCubit.get(context).userModel?.image ?? '',
                          segments: myStories.length,
                          radius: 32,
                          onTap: () async {
                            final filteredStories = myStories.where((story) =>
                              (story['imageUrl'] != null && story['imageUrl'].toString().isNotEmpty) ||
                              (story['text'] != null && story['text'].toString().isNotEmpty)
                            ).toList();
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StoryViewScreen(
                                  stories: filteredStories,
                                  userName: SocialCubit.get(context).userModel?.name ?? '',
                                  userImage: SocialCubit.get(context).userModel?.image ?? '',
                                ),
                              ),
                            );
                            if (!mounted) return;
                            if (result == true) {
                              SocialCubit.get(context).getStories();
                            }
                          },
                        ),
                        SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              SocialCubit.get(context).userModel?.name ?? '',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            SizedBox(height: 2),
                            Text(
                              myStories.last['timestamp'] != null
                                  ? (myStories.last['timestamp'] is DateTime
                                      ? '${myStories.last['timestamp'].hour.toString().padLeft(2, '0')}:${myStories.last['timestamp'].minute.toString().padLeft(2, '0')}'
                                      : '')
                                  : '',
                              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                // معاينة الصورة المختارة
                if (_selectedImagePath != null) ...[
                  SizedBox(height: 20),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(_selectedImagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: state is SocialUploadStoryLoadingState || state is SocialUploadTextStatusLoadingState
                              ? null
                              : () => _uploadStory(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KMainColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: state is SocialUploadStoryLoadingState || state is SocialUploadTextStatusLoadingState
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('Upload Status'),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedImagePath = null;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text('Cancel'),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 20),
                Text(
                  'Recent Updates',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                if (SocialCubit.get(context).storiesList.entries.where((entry) => entry.key != SocialCubit.get(context).userModel?.uId).isNotEmpty)
                  ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: SocialCubit.get(context).storiesList.entries
                      .where((entry) => entry.key != SocialCubit.get(context).userModel?.uId)
                      .map((entry) {
                        final userStories = entry.value;
                        final latestStory = userStories.first;
                        final lastStory = userStories.last;
                        final filteredStories = userStories.where((story) =>
                          (story['imageUrl'] != null && story['imageUrl'].toString().isNotEmpty) ||
                          (story['text'] != null && story['text'].toString().isNotEmpty)
                        ).toList();
                        DateTime? storyTime;
                        if (lastStory['timestamp'] != null) {
                          if (lastStory['timestamp'] is DateTime) {
                            storyTime = lastStory['timestamp'];
                          } else if (lastStory['timestamp'] is String) {
                            storyTime = DateTime.tryParse(lastStory['timestamp']);
                          } else if (lastStory['timestamp'] is Timestamp) {
                            storyTime = (lastStory['timestamp'] as Timestamp).toDate();
                          }
                        }
                        String timeString = storyTime != null
                            ? '${storyTime.hour.toString().padLeft(2, '0')}:${storyTime.minute.toString().padLeft(2, '0')}'
                            : '';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              StoryCircle(
                                imageUrl: latestStory['userImage'] ?? '',
                                segments: filteredStories.length,
                                radius: 32,
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StoryViewScreen(
                                        stories: filteredStories,
                                        userName: latestStory['userName'],
                                        userImage: latestStory['userImage'],
                                      ),
                                    ),
                                  );
                                  if (!mounted) return;
                                  if (result == true) {
                                    SocialCubit.get(context).getStories();
                                  }
                                },
                              ),
                              SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    latestStory['userName'] ?? '',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    timeString,
                                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      
      if (pickedFile != null) {
        setState(() {
          _selectedImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showTextStatusDialog() async {
    await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('اكتب حالتك'),
          content: TextField(
            controller: _statusController,
            decoration: InputDecoration(hintText: 'اكتب هنا...'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                if (_statusController.text.trim().isNotEmpty) {
                  Navigator.pop(context);
                  _uploadTextStatus();
                }
              },
              child: Text('نشر'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadStory() async {
    if (_selectedImagePath != null) {
      SocialCubit.get(context).uploadStory(
        imagePath: _selectedImagePath!,
        text: '',
      );
    }
  }

  Future<void> _uploadTextStatus() async {
    if (_statusController.text.trim().isNotEmpty) {
      SocialCubit.get(context).uploadTextStatus(
        text: _statusController.text.trim(),
      );
    }
  }
}
