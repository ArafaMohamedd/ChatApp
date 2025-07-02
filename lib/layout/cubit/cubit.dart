import 'dart:io';

import 'package:chatnew/core/utils/constants.dart';
import 'package:chatnew/models/social_app/message_model.dart';
import 'package:chatnew/models/social_app/social_user_model.dart';
import 'package:chatnew/models/social_app/user_model.dart';
import 'package:chatnew/modules/social_app/chats/chats_screen.dart';
import 'package:chatnew/modules/social_app/setting_1/setting_screen1.dart';
import 'package:chatnew/modules/social_app/settings_2/setting_screens2.dart';
import 'package:chatnew/modules/social_app/updates%20status/states_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatnew/layout/cubit/states.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class SocialCubit extends Cubit<SocialStates>
{
  SocialCubit() : super(SocialInitialState());

  static SocialCubit get(context) => BlocProvider.of(context);

  SocialUserModel? userModel;
  List<SocialUserModel> users = [];
  List<SocialUserModel> allUsers = [];
  List<MessageModel> messages = [];
  Map<String, List<Map<String, dynamic>>> storiesList = {};

  void getUserData() {
    print('getUserData called with uId: $uId'); // Debug print
    
    if (uId == null || uId!.isEmpty) {
      print('uId is null or empty, cannot get user data'); // Debug print
      emit(SocialGetUserLoadingState('User ID is empty'));
      return;
    }

    print('Fetching user data from Firestore for uId: $uId'); // Debug print
    
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId) // Ensure uId is not null
        .get()
        .then((value) {
      if (value.exists) {
        final data = value.data();
        print('User data retrieved: ${data?['email']} - ${data?['name']}'); // Debug print
        if (data != null) {
          userModel = SocialUserModel.fromjson(data); // Pass non-null data
          print('User model set: ${userModel!.email} - ${userModel!.name}'); // Debug print
          emit(SocialGetUserSuccessState());
        } else {
          print('User data is null'); // Debug print
          emit(SocialGetUserErrorState('User data is null'));
        }
      } else {
        print('User document does not exist for uId: $uId'); // Debug print
        emit(SocialGetUserErrorState('User does not exist'));
      }
    }).catchError((error) {
      print('Error getting user data: $error'); // Debug print
      emit(SocialGetUserErrorState(error.toString()));
    });
  }

  int currentIndex = 0;

  List<Widget> screens = [
    ChatsScreen(),
    StatesScreen(),
    SettingsScreen1(),
  ];

  List<String> titles = [
    'Chats',
    'Status',
    'Setting',
  ];

  void changeBottomNav( int index) {

    if(index == 0 && users.isEmpty){
      getUsers();
    }

    currentIndex = index;
    emit(SocialChangeBottomNavState());
  }

  File? profileImage;
  var  picker = ImagePicker();

  Future<void> getProfileImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      profileImage = File(pickedFile.path);
      emit(SocialProfileImagePickedSuccessState());
    } else
    {
      print('No image selected.');
      emit(SocialProfileImagePickedErrorState());
    }
  }

  File? coverImage;


  Future<void> getCoverImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      coverImage = File(pickedFile.path);
      emit(SocialCoverImagePickedSuccessState());
    } else
    {
      print('No image selected.');
      emit(SocialCovereImagePickedErrorState());
    }
  }



void updateUser({
  required String name,
  required String phone,
  required String bio,
})
{
  emit(SocialUserUpdateLoadingState());

  SocialUserModel model = SocialUserModel(
    name: name,
    email: userModel!.email,
    phone: phone,
    uId: userModel!.uId,
    bio: bio,
    cover: 'https://img.freepik.com/premium-vector/vector-ramadan-kareem-lantern-hanging-chains-composition_694085-192.jpg?w=1380',
    image: 'https://m.media-amazon.com/images/I/51q4sgCtasL.jpg',
    isEmailVerified: false,
  );

  FirebaseFirestore
      .instance
      .collection('users')
      .doc(userModel!.uId)
      .update(model.toMap())
      .then((value) {
        getUserData();
  })
      .catchError((error) {
        emit(SocialUserUpdateErrorState());
  });
}

  void getUsers(){
    if(users.length == 0)
    print('yes get user Arafa');
       FirebaseFirestore.instance.collection('users').get().then((value) {
         print(value);
         print('ARAFA');
         value.docs.forEach((element)
         {
            if(element.data()['uId'] != userModel!.uId)
           users.add(SocialUserModel.fromjson(element.data()));
         });
         emit(SocialGetAllUsersSuccessState());
       }).
       catchError((error){
         print(error.toString());
         emit(SocialGetAllUsersErrorState(error.toString()));
       }
       );
  }

  void sendMessage({
    required String receiverId,
    required String dataTime,
    required String text,
    List<String> attachments = const [],
    String? imagePath,
    String? localAudioPath,  // For local audio files
    String? voiceMessageUrl, // For uploaded audio URLs
  }) {
    MessageModel model = MessageModel(
      text: text,
      senderId: userModel!.uId,
      receiverId: receiverId,
      dateTime: dataTime,
      attachments: attachments,
      localImagePath: imagePath,
      localAudioPath: localAudioPath,
      voiceMessageUrl: voiceMessageUrl,
    );

    // Create a unique chat ID (sorted to ensure consistency)
    List<String> userIds = [userModel!.uId!, receiverId];
    userIds.sort();
    String chatId = userIds.join('_');

    // Save to separate messages collection
    FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection('chat_messages')
        .add(model.toMap())
        .then((value) {
      print('Message saved successfully to chat: $chatId');
      
      // Update chat status for both users
      _updateChatStatus(receiverId, dataTime, text, attachments.isNotEmpty);
      
      emit(SocialSendMessageSuccessState());
    }).catchError((error) {
      print('Error saving message: $error');
      emit(SocialSendMessageErrorState());
    });
  }

  // Update chat status for both users
  void _updateChatStatus(String receiverId, String dataTime, String text, bool hasAttachments) {
    // Update current user's chat status
    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.uId)
        .collection('chats')
        .doc(receiverId)
        .set({
      'lastMessage': hasAttachments ? '[Media]' : text,
      'lastMessageTime': dataTime,
      'lastMessageSender': userModel!.uId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Update receiver's chat status
    FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(userModel!.uId)
        .set({
      'lastMessage': hasAttachments ? '[Media]' : text,
      'lastMessageTime': dataTime,
      'lastMessageSender': userModel!.uId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void getMessages({
    required String receiverId
})
  {
    print('Getting messages for receiverId: $receiverId');
    print('Current user ID: ${userModel!.uId}');
    
    // Create a unique chat ID (sorted to ensure consistency)
    List<String> userIds = [userModel!.uId!, receiverId];
    userIds.sort();
    String chatId = userIds.join('_');
    
    print('Chat ID: $chatId');
    
    FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection('chat_messages')
        .orderBy('dateTime')
        .snapshots()
        .listen((event)
    {
        print('Messages snapshot received: ${event.docs.length} messages');
        messages = [];

        event.docs.forEach((element)
        {
            try {
              messages.add(MessageModel.fromjson(element.data()));
            } catch (e) {
              print('Error parsing message: $e');
              print('Message data: ${element.data()}');
            }
        });
        print('Total messages loaded: ${messages.length}');
        
        // If no messages found, try to migrate old messages
        if (messages.isEmpty) {
          print('No messages found in new structure, attempting migration...');
          migrateOldMessages(receiverId);
        }
        
        emit(SocialGetMessageSuccessState());
    }, onError: (error) {
      print('Error in getMessages: $error');
      print('Error type: ${error.runtimeType}');
      emit(SocialGetMessageErrorState(error.toString()));
    });
  }

  // Optional: Function to migrate old messages to new structure
  void migrateOldMessages(String receiverId) {
    print('Migrating old messages for receiverId: $receiverId');
    
    // Get old messages from sender's side
    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .get()
        .then((oldMessages) {
      if (oldMessages.docs.isNotEmpty) {
        print('Found ${oldMessages.docs.length} old messages to migrate');
        
        // Create new chat ID
        List<String> userIds = [userModel!.uId!, receiverId];
        userIds.sort();
        String chatId = userIds.join('_');
        
        // Migrate each message
        for (var doc in oldMessages.docs) {
          FirebaseFirestore.instance
              .collection('messages')
              .doc(chatId)
              .collection('chat_messages')
              .add(doc.data())
              .then((_) => print('Message migrated: ${doc.id}'));
        }
      }
    }).catchError((error) {
      print('Error migrating messages: $error');
    });
  }

  // Send message and return the message ID
  Future<String> sendMessageWithId({
    required String receiverId,
    required String dataTime,
    required String text,
    List<String> attachments = const [],
    String? imagePath,
    String? localAudioPath,
    String? voiceMessageUrl,
  }) async {
    MessageModel model = MessageModel(
      text: text,
      senderId: userModel!.uId,
      receiverId: receiverId,
      dateTime: dataTime,
      attachments: attachments,
      localImagePath: imagePath,
      localAudioPath: localAudioPath,
      voiceMessageUrl: voiceMessageUrl,
    );

    // Create a unique chat ID (sorted to ensure consistency)
    List<String> userIds = [userModel!.uId!, receiverId];
    userIds.sort();
    String chatId = userIds.join('_');

    // Save to separate messages collection and get the document reference
    final docRef = await FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection('chat_messages')
        .add(model.toMap());

    print('Message saved successfully to chat: $chatId with ID: ${docRef.id}');
    emit(SocialSendMessageSuccessState());
    
    return docRef.id;
  }

  // Update message with voice URL
  Future<void> updateMessageWithVoiceUrl(String messageId, String voiceUrl) async {
    try {
      // Find the message in all chats and update it
      final chatsQuery = await FirebaseFirestore.instance
          .collection('messages')
          .get();

      for (var chatDoc in chatsQuery.docs) {
        final messageRef = chatDoc.reference
            .collection('chat_messages')
            .doc(messageId);
        
        final messageDoc = await messageRef.get();
        if (messageDoc.exists) {
          await messageRef.update({
            'voiceMessageUrl': voiceUrl,
          });
          print('Message updated with voice URL: $messageId');
          break;
        }
      }
    } catch (e) {
      print('Error updating message with voice URL: $e');
      throw e;
    }
  }

  // Upload story with image
  Future<void> uploadStory({
    required String imagePath,
    required String text,
  }) async {
    emit(SocialUploadStoryLoadingState());
    
    try {
      final file = File(imagePath);
      if (!await file.exists()) throw Exception("Image file not found");

      // Create unique filename
      final fileName = '${Uuid().v1()}.jpg';
      final ref = FirebaseStorage.instance
          .ref('stories/${userModel!.uId}/$fileName');

      // Upload file
      final uploadTask = ref.putFile(file);
      final taskSnapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Save story to Firestore
      await FirebaseFirestore.instance
          .collection('stories')
          .add({
        'userId': userModel!.uId,
        'userName': userModel!.name,
        'userImage': userModel!.image,
        'imageUrl': downloadUrl,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(Duration(hours: 24)), // Stories expire after 24 hours
      });

      print('Story uploaded successfully: $downloadUrl');
      emit(SocialUploadStorySuccessState());
    } catch (e) {
      print('Story upload error: $e');
      emit(SocialUploadStoryErrorState());
    }
  }

  // Upload text status
  Future<void> uploadTextStatus({
    required String text,
  }) async {
    emit(SocialUploadTextStatusLoadingState());
    
    try {
      // Save text status to Firestore
      await FirebaseFirestore.instance
          .collection('stories')
          .add({
        'userId': userModel!.uId,
        'userName': userModel!.name,
        'userImage': userModel!.image,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(Duration(hours: 24)), // Stories expire after 24 hours
      });

      print('Text status uploaded successfully');
      emit(SocialUploadTextStatusSuccessState());
    } catch (e) {
      print('Text status upload error: $e');
      emit(SocialUploadTextStatusErrorState());
    }
  }

  // Get stories from Firestore
  Future<void> getStories() async {
    try {
      // Get current timestamp
      final now = DateTime.now();
      
      // Query stories that haven't expired yet
      final storiesQuery = await FirebaseFirestore.instance
          .collection('stories')
          .where('expiresAt', isGreaterThan: now)
          .orderBy('expiresAt', descending: true)
          .get();

      final stories = storiesQuery.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'userId': data['userId'],
          'userName': data['userName'],
          'userImage': data['userImage'],
          'imageUrl': data['imageUrl'],
          'text': data['text'],
          'timestamp': data['timestamp'],
          'expiresAt': data['expiresAt'],
        };
      }).toList();

      // Group stories by user
      final Map<String, List<Map<String, dynamic>>> groupedStories = {};
      for (var story in stories) {
        final userId = story['userId'];
        if (!groupedStories.containsKey(userId)) {
          groupedStories[userId] = [];
        }
        groupedStories[userId]!.add(story);
      }
      // تتبع عدد الاستوريهات لكل مستخدم
      print('عدد الاستوريهات لكل مستخدم:');
      groupedStories.forEach((key, value) {
        print('userId: $key, count: [32m${value.length}[0m');
      });

      // Store stories in cubit state
      storiesList = groupedStories;
      emit(SocialGetStoriesSuccessState());
    } catch (e) {
      print('Get stories error: $e');
      emit(SocialGetStoriesErrorState());
    }
  }

  Future<void> uploadProfileImageAndUpdateUser({
    required String name,
    required String phone,
    required String bio,
  }) async {
    emit(SocialUserUpdateLoadingState());
    String? imageUrl = userModel?.image;

    // إذا تم اختيار صورة جديدة
    if (profileImage != null) {
      final file = File(profileImage!.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('users')
          .child('${userModel!.uId}.jpg');
      await ref.putFile(file);
      imageUrl = await ref.getDownloadURL();
    }

    SocialUserModel model = SocialUserModel(
      name: name,
      email: userModel!.email,
      phone: phone,
      uId: userModel!.uId,
      bio: bio,
      cover: userModel!.cover,
      image: imageUrl,
      isEmailVerified: userModel!.isEmailVerified,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.uId)
        .update(model.toMap());

    getUserData();
    emit(SocialUserUpdateSuccessState());
  }
}