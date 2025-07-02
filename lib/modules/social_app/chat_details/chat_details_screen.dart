import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:chatnew/core/utils/constants.dart';
import 'package:chatnew/layout/cubit/cubit.dart';
import 'package:chatnew/layout/cubit/states.dart';
import 'package:chatnew/models/social_app/message_model.dart';
import 'package:chatnew/models/social_app/social_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:record/record.dart';
import 'package:file_picker/file_picker.dart';


class ChatDetailsScreen extends StatefulWidget {
  ChatDetailsScreen({Key? key, required this.userModel, }) : super(key: key);

  final SocialUserModel userModel;

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final TextEditingController messageController = TextEditingController();
  String image= '';
  var Imag;
  String? _imagePath;
  bool _showImagePreview = false;
  final record=AudioRecorder();
  String path= '';
  String url= '';
  bool is_record = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  String? recordedFilePath;

  void _startTimer() {
    _recordingTimer?.cancel();
    _recordingDuration = Duration.zero;
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration += Duration(seconds: 1);
      });
    });
  }

// Update your stopRecording/cancelRecording
  void _stopTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  //String image;
  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (context)
        {
          SocialCubit.get(context).getMessages(receiverId: widget.userModel.uId!);

          return BlocConsumer<SocialCubit, SocialStates>(
            listener: (context, state) {},
            builder: (context, state) {
              return  Scaffold(
                appBar: AppBar(
                  titleSpacing: 0.0,
                  title: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22.0,
                          backgroundImage: NetworkImage(
                              widget.userModel.image ?? ''
                          ),
                        ),
                        SizedBox(width: 12.0,),
                        Expanded(
                          child: Text(widget.userModel.name ?? '', style: TextStyle(fontSize: 15),
                            overflow: TextOverflow.ellipsis,),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    // Search button
                    IconButton(
                      icon: Icon(Icons.search, color: Colors.grey),
                      onPressed: () {
                        _showSearchDialog();
                      },
                    ),
                    SizedBox(width: 10),
                    PopupMenuButton(
                      onSelected: (e) async {
                        if (e == 'delete') {
                          final confirmed = await _showDeleteConfirmationDialog(context);
                          if (confirmed) {
                            await _deleteChat(context);
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Text('Delete chat'),
                          value: 'delete',
                        )
                      ],
                    )
                  ],
                ),
                body: ConditionalBuilder(
                  condition: SocialCubit.get(context).messages.length > 0,
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                              physics: BouncingScrollPhysics(),

                              itemBuilder: (context, index)
                              {
                                var message = SocialCubit.get(context).messages[index];

                                if(SocialCubit.get(context).userModel?.uId == message.senderId)
                                  return buildMyMessage(message);

                                return buildMessage(message);
                              },
                              separatorBuilder: (context, index) => SizedBox(
                                height: 15.0,
                              ),
                              itemCount: SocialCubit.get(context).messages.length
                          ),
                        ),
                        // معاينة الصورة - مثل الستوري في واتساب
                        if (_showImagePreview && _imagePath != null)
                          _buildImagePreview(),
                        _buildMessageInput(),
                      ],
                    ),
                  ),
                  fallback: (context) => Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No messages yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Start a conversation with ${widget.userModel.name}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // معاينة الصورة - مثل الستوري في واتساب
                        if (_showImagePreview && _imagePath != null)
                          _buildImagePreview(),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromARGB(255, 53, 52, 52) ?? Colors.grey,
                                  width: 1.0
                              ),
                              borderRadius: BorderRadius.circular(28.0)
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.attach_file, color: KMainColor),
                                onPressed: () {
                                  _showAttachmentOptions(context);
                                },
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 0.0),
                                    child: TextFormField(
                                      controller: messageController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'message',
                                        hintStyle: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onChanged: (text) {
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.camera_alt_outlined, color: KMainColor),
                                onPressed: () {
                                  open_image_camera();
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  messageController.text.isNotEmpty
                                      ? Icons.send
                                      : (is_record ? Icons.stop : Icons.mic),
                                  color: KMainColor,
                                ),
                                onPressed: () {
                                  if (messageController.text.isNotEmpty) {
                                    SocialCubit.get(context).sendMessage(
                                      receiverId: widget.userModel.uId!,
                                      dataTime: DateTime.now().toString(),
                                      text: messageController.text,
                                      attachments: [],
                                    );
                                    messageController.clear();
                                  } else {
                                    if (!is_record) {
                                      startRecording();
                                    } else {
                                      stopRecording();
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
    );
  }



  Widget buildMessage(MessageModel model) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        decoration: BoxDecoration(
          color: KMainColor,
          borderRadius: BorderRadiusDirectional.only(
            bottomEnd: Radius.circular(10.0),
            topStart: Radius.circular(10.0),
            topEnd: Radius.circular(10.0),
          ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 12.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (model.localImagePath != null && model.localImagePath!.isNotEmpty)
              GestureDetector(
                onTap: ()=> _showFullScreenImage(context, model.localImagePath!),
                child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: FileImage(File(model.localImagePath!)),
                        fit: BoxFit.cover,
                      ),
                    )
                ),
              ),
            if (model.attachments != null && model.attachments!.isNotEmpty)
              for (String attachment in model.attachments!)
                if (attachment.contains('chat_images'))
                  GestureDetector(
                    onTap: () => _showFullScreenImageFromUrl(context, attachment),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(attachment),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            print('Error loading image: $exception');
                          },
                        ),
                      ),
                    ),
                  ),
            if (model.voiceMessageUrl != null) _buildVoiceMessageWidget(model),
            if (model.text != null && model.text!.isNotEmpty)
              Text(model.text!, style: TextStyle(color: Colors.white)),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (model.attachments != null && model.attachments!.isNotEmpty)
                  Row(
                    children: List.generate(
                      model.attachments!.length > 2 ? 2 : model.attachments!.length,
                          (index) => Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.attach_file,
                          size: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                SizedBox(width: 8),
                Text(
                  _formatTime(model.dateTime),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMyMessage(MessageModel model) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[600],
          borderRadius: BorderRadiusDirectional.only(
            bottomStart: Radius.circular(10.0),
            topStart: Radius.circular(10.0),
            topEnd: Radius.circular(10.0),
          ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 12.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (model.localImagePath != null && model.localImagePath!.isNotEmpty)
              GestureDetector(
                onTap: () => _showFullScreenImage(context, model.localImagePath!),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: FileImage(File(model.localImagePath!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            if (model.attachments != null && model.attachments!.isNotEmpty)
              for (String attachment in model.attachments!)
                if (attachment.contains('chat_images'))
                  GestureDetector(
                    onTap: () => _showFullScreenImageFromUrl(context, attachment),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(attachment),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            print('Error loading image: $exception');
                          },
                        ),
                      ),
                    ),
                  ),
            if (model.voiceMessageUrl != null) _buildVoiceMessageWidget(model),
            if (model.text != null && model.text!.isNotEmpty)
              Text(model.text!, style: TextStyle(color: Colors.white)),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(model.dateTime),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
                if (model.attachments != null && model.attachments!.isNotEmpty)
                  SizedBox(width: 8),
                if (model.attachments != null && model.attachments!.isNotEmpty)
                  Row(
                    children: List.generate(
                      model.attachments!.length > 2 ? 2 : model.attachments!.length,
                          (index) => Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.attach_file,
                          size: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingUI() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(28.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.mic, color: Colors.red),
          SizedBox(width: 8),
          Text(
            "Recording: ${_recordingDuration.inSeconds}s",
            style: TextStyle(color: Colors.red),
          ),
          Spacer(),
          GestureDetector(
            onTap: cancelRecording,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.2),
              ),
              child: Icon(Icons.close, color: Colors.red, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceMessageWidget(MessageModel model) {
    final audioPlayer = AudioPlayer();
    bool isPlaying = false;
    Duration? duration;
    Duration? position;

    return StatefulBuilder(
      builder: (context, setState) {
        // Setup listeners
        audioPlayer.onPlayerStateChanged.listen((state) {
          setState(() => isPlaying = state == PlayerState.playing);
        });
        audioPlayer.onDurationChanged.listen((newDuration) {
          setState(() => duration = newDuration);
        });
        audioPlayer.onPositionChanged.listen((newPosition) {
          setState(() => position = newPosition);
        });

        String formatDuration(Duration? d) {
          if (d == null) return "0:00";
          String twoDigits(int n) => n.toString().padLeft(2, '0');
          final minutes = d.inMinutes;
          final seconds = d.inSeconds % 60;
          return "$minutes:${twoDigits(seconds)}";
        }

        return Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[600],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Play/Pause button
              InkWell(
                onTap: () async {
                  if (isPlaying) {
                    await audioPlayer.pause();
                  } else {
                    if (model.localAudioPath != null && model.localAudioPath!.isNotEmpty) {
                      await audioPlayer.play(DeviceFileSource(model.localAudioPath!));
                    } else if (model.voiceMessageUrl != null && model.voiceMessageUrl!.isNotEmpty) {
                      await audioPlayer.play(UrlSource(model.voiceMessageUrl!));
                    }
                  }
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              SizedBox(width: 12),
              // Progress bar
              if (duration != null && position != null)
                Expanded(
                  child: Slider(
                    value: position!.inMilliseconds.toDouble(),
                    min: 0,
                    max: duration!.inMilliseconds.toDouble(),
                    onChanged: (value) async {
                      await audioPlayer.seek(Duration(milliseconds: value.toInt()));
                    },
                    activeColor: Colors.white,
                    inactiveColor: Colors.white24,
                  ),
                )
              else
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              SizedBox(width: 12),
              // Duration
              Text(
                formatDuration(duration ?? position),
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> startRecording() async {
    try {
      // Check if recording is already in progress
      if (is_record) return;

      // Check and request permissions
      final isPermissionGranted = await record.hasPermission();
      if (!isPermissionGranted) {
        final permissionStatus = await Permission.microphone.request();
        if (permissionStatus != PermissionStatus.granted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission denied')),
          );
          return;
        }
      }

      // Create directory if not exists
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/recordings';
      await Directory(path).create(recursive: true);

      // Start recording
      await record.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: '$path/${DateTime.now().millisecondsSinceEpoch}.m4a',
      );

      setState(() {
        is_record = true;
        _startTimer();
      });

    } catch (e) {
      print('Recording error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording')),
      );
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await record.stop();
      if (path != null && path.isNotEmpty) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(child: CircularProgressIndicator()),
        );
        
        // First send with local path and get message ID
        final messageId = await SocialCubit.get(context).sendMessageWithId(
          receiverId: widget.userModel.uId!,
          dataTime: DateTime.now().toString(),
          text: '[Voice Message]',
          localAudioPath: path,
          attachments: [],
        );

        // Close loading dialog
        Navigator.pop(context);

        // Then upload and update with URL
        await uploadRecording(path, messageId);
      }
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      print('Stop recording error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to stop recording')),
      );
    } finally {
      setState(() {
        is_record = false;
        _stopTimer();
      });
    }
  }

  Future<void> uploadRecording(String filePath, String messageId) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) throw Exception("Recording file not found");

      final ref = FirebaseStorage.instance
          .ref('voice_messages/${widget.userModel.uId}/${Uuid().v1()}.m4a');

      final uploadTask = ref.putFile(file);
      final taskSnapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      print('Voice message uploaded successfully: $downloadUrl');
      
      // Update the message with the URL
      await SocialCubit.get(context).updateMessageWithVoiceUrl(messageId, downloadUrl);
      
    } catch (e) {
      print('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload voice message')),
      );
    }
  }

  Future<void> cancelRecording() async {
    try {
      await record.stop();
      File(path).delete(); // Delete the recording file
      setState(() {
        is_record = false;
        path = '';
      });
    } catch (e) {
      print('Cancel recording error: $e');
    }
  }


  void _showFullScreenImage(BuildContext context, String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: FutureBuilder<File>(
            future: Future.value(File(imagePath)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading image'));
                }
                return Center(
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.file(snapshot.data!),
                  ),
                );
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  void _showFullScreenImageFromUrl(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.white, size: 50),
                        SizedBox(height: 16),
                        Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / 
                            loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> open_image_gallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
        _showImagePreview = true;
      });
    }
  }

  Future<void> open_image_camera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
        _showImagePreview = true;
      });
    }
  }

  void showAndsend() {
    showModalBottomSheet(
      context: context,
      builder: (c) => Container(
        color: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: _imagePath != null
                  ? Image.file(File(_imagePath!), fit: BoxFit.contain)
                  : Center(child: Text('No image selected')),
            ),
            SizedBox(height: 10.0),
            InkWell(
              onTap: () async {
                if (_imagePath != null) {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Center(child: CircularProgressIndicator()),
                  );
                  
                  try {
                    // Upload image to Firebase Storage
                    final imageUrl = await uploadImage(_imagePath!);
                    
                    // Close loading dialog
                    Navigator.pop(context);
                    
                    // Send message with image URL
                    SocialCubit.get(context).sendMessage(
                      receiverId: widget.userModel.uId!,
                      dataTime: DateTime.now().toString(),
                      text: '', // Optional caption
                      imagePath: _imagePath, // Keep local path for immediate display
                      attachments: [imageUrl], // Add URL to attachments
                    );
                    
                    // Clear image path
                    setState(() {
                      _imagePath = null;
                    });
                    
                    Navigator.pop(context);
                  } catch (e) {
                    // Close loading dialog
                    Navigator.pop(context);
                    
                    // Show error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to upload image: $e')),
                    );
                  }
                }
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: KMainColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Send',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> uploadImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) throw Exception("Image file not found");

      // Create unique filename
      final fileName = '${Uuid().v1()}.jpg';
      final ref = FirebaseStorage.instance
          .ref('chat_images/${widget.userModel.uId}/$fileName');

      // Upload file
      final uploadTask = ref.putFile(file);
      final taskSnapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      print('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Image upload error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String> uploadDocument(String filePath, String fileName) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) throw Exception("Document file not found");

      // Create unique filename
      final uniqueFileName = '${Uuid().v1()}_$fileName';
      final ref = FirebaseStorage.instance
          .ref('chat_documents/${widget.userModel.uId}/$uniqueFileName');

      // Upload file
      final uploadTask = ref.putFile(file);
      final taskSnapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      print('Document uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Document upload error: $e');
      throw Exception('Failed to upload document: $e');
    }
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Camera'),
            onTap: () {
              open_image_camera();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo),
            title: Text('Gallery'),
            onTap: () {
              open_image_gallery();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.insert_drive_file),
            title: Text('Document'),
            onTap: () {
              open_document_picker();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> open_document_picker() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      // Pick document file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx'],
        allowMultiple: false,
      );

      // Close loading dialog
      Navigator.pop(context);

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final filePath = file.path;
        final fileName = file.name;

        if (filePath != null) {
          // Show preview dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Send Document'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.insert_drive_file, color: KMainColor),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fileName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('Size: ${(file.size / 1024).toStringAsFixed(1)} KB'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    
                    // Show upload progress
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                        content: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Text('Uploading document...'),
                          ],
                        ),
                      ),
                    );

                    try {
                      // Upload document to Firebase Storage
                      final documentUrl = await uploadDocument(filePath, fileName);
                      
                      // Close upload dialog
                      Navigator.pop(context);
                      
                      // Send message with document
                      SocialCubit.get(context).sendMessage(
                        receiverId: widget.userModel.uId!,
                        dataTime: DateTime.now().toString(),
                        text: '[Document: $fileName]',
                        attachments: [documentUrl],
                      );
                      
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Document sent successfully')),
                      );
                    } catch (e) {
                      // Close upload dialog
                      Navigator.pop(context);
                      
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to send document: $e')),
                      );
                    }
                  },
                  child: Text('Send'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      Navigator.pop(context);
      
      print('Document picker error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open document picker: $e')),
      );
    }
  }

  String _formatTime(String? dateTime) {
    if (dateTime == null) return '';
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Chat'),
        content: Text('Are you sure you want to delete this chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          )],
      ),
    ) ?? false;
  }

  Future<void> _deleteChat(BuildContext context) async {
    final cubit = SocialCubit.get(context);
    final currentUserId = cubit.userModel?.uId;
    final otherUserId = widget.userModel.uId;

    if (currentUserId == null || otherUserId == null) return;

    try {
      // Delete messages from current user's side
      final currentUserChatRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .doc(otherUserId);

      // Delete messages from other user's side
      final otherUserChatRef = FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
          .collection('chats')
          .doc(currentUserId);

      // Batch delete for atomic operation
      final batch = FirebaseFirestore.instance.batch();
      batch.delete(currentUserChatRef);
      batch.delete(otherUserChatRef);

      await batch.commit();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chat deleted successfully')),
      );

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete chat: ${e.toString()}')),
      );
    }
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      child: Row(
        children: [
          // Attach file button - أقصى اليسار
          IconButton(
            icon: Icon(Icons.attach_file, color: KMainColor),
            onPressed: () {
              _showAttachmentOptions(context);
            },
            splashRadius: 24,
          ),
          // Message input container - موسع
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(32.0),
              ),
              child: Row(
                children: [
                  // Message input
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextFormField(
                        controller: messageController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'message',
                          hintStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onChanged: (text) {
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  // Send button - داخل الحقل
                  Builder(
                    builder: (context) {
                      if (messageController.text.trim().isNotEmpty) {
                        // إذا كان هناك نص، اعرض زر الإرسال
                        return GestureDetector(
                          onTap: () {
                            if (messageController.text.trim().isNotEmpty) {
                              SocialCubit.get(context).sendMessage(
                                receiverId: widget.userModel.uId!,
                                dataTime: DateTime.now().toString(),
                                text: messageController.text,
                              );
                              messageController.clear();
                              setState(() {});
                            }
                          },
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: KMainColor,
                            child: Icon(Icons.send, color: Colors.white),
                          ),
                        );
                      } else {
                        // إذا كان الحقل فارغ، اعرض زر فارغ أو أيقونة فارغة
                        return SizedBox(
                          width: 48,
                          height: 48,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          // Mic/Record button - خارج الحقل
          Builder(
            builder: (context) {
              if (is_record) {
                // أثناء التسجيل: دائرة فيها عداد
                return GestureDetector(
                  onTap: () async {
                    await stopRecording();
                    setState(() {
                      is_record = false;
                      // recordedFilePath will be set in stopRecording
                    });
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.red.withOpacity(0.15),
                    child: Text(
                      '${_recordingDuration.inSeconds}',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                );
              } else if (recordedFilePath != null && recordedFilePath!.isNotEmpty) {
                // بعد التسجيل: زر إرسال الصوت
                return Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // Send the recorded voice
                        SocialCubit.get(context).sendMessage(
                          receiverId: widget.userModel.uId!,
                          dataTime: DateTime.now().toString(),
                          text: '[Voice Message]',
                          localAudioPath: recordedFilePath,
                          attachments: [],
                        );
                        setState(() {
                          recordedFilePath = null;
                        });
                      },
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: KMainColor,
                        child: Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        // إعادة التسجيل
                        await startRecording();
                        setState(() {
                          recordedFilePath = null;
                        });
                      },
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey[400],
                        child: Icon(Icons.mic, color: Colors.white),
                      ),
                    ),
                  ],
                );
              } else {
                // زر المايك العادي
                return GestureDetector(
                  onTap: () async {
                    await startRecording();
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: KMainColor,
                    child: Icon(Icons.mic, color: Colors.white),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    final TextEditingController searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search in Chat'),
        content: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search for messages...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (query) {
            // يمكن إضافة منطق البحث هنا
            print('Searching for: $query');
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // يمكن إضافة منطق البحث هنا
              if (searchController.text.trim().isNotEmpty) {
                print('Searching for: ${searchController.text}');
                // هنا يمكنك إضافة منطق البحث في الرسائل
              }
              Navigator.pop(context);
            },
            child: Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          // معاينة الصورة
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(_imagePath!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 10),
          // أزرار الإرسال والإلغاء
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // زر الإلغاء
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: 5),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _imagePath = null;
                        _showImagePreview = false;
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
                ),
              ),
              // زر الإرسال
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 5),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_imagePath != null) {
                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => Center(child: CircularProgressIndicator()),
                        );
                        
                        try {
                          // Upload image to Firebase Storage
                          final imageUrl = await uploadImage(_imagePath!);
                          
                          // Close loading dialog
                          Navigator.pop(context);
                          
                          // Send message with image URL
                          SocialCubit.get(context).sendMessage(
                            receiverId: widget.userModel.uId!,
                            dataTime: DateTime.now().toString(),
                            text: '', // Optional caption
                            imagePath: _imagePath, // Keep local path for immediate display
                            attachments: [imageUrl], // Add URL to attachments
                          );
                          
                          // Clear image path and hide preview
                          setState(() {
                            _imagePath = null;
                            _showImagePreview = false;
                          });
                          
                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Image sent successfully!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          
                          // Force refresh messages
                          SocialCubit.get(context).getMessages(receiverId: widget.userModel.uId!);
                          
                        } catch (e) {
                          // Close loading dialog
                          Navigator.pop(context);
                          
                          // Show error
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to upload image: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KMainColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Send'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}