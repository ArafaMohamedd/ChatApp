import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatnew/layout/cubit/cubit.dart';

class StoryViewScreen extends StatefulWidget {
  final List<Map<String, dynamic>> stories;
  final String userName;
  final String userImage;

  const StoryViewScreen({
    Key? key,
    required this.stories,
    required this.userName,
    required this.userImage,
  }) : super(key: key);

  @override
  _StoryViewScreenState createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  List<Map<String, dynamic>> _stories = [];

  @override
  void initState() {
    super.initState();
    _stories = List<Map<String, dynamic>>.from(widget.stories);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _deleteCurrentStory() async {
    if (_stories.isEmpty) return;
    final story = _stories[_currentIndex];
    final storyId = story['id'];
    if (storyId != null) {
      await FirebaseFirestore.instance.collection('stories').doc(storyId).delete();
      setState(() {
        _stories.removeAt(_currentIndex);
        Navigator.of(context).pop(true);
      });
      Future.delayed(Duration(milliseconds: 100), () {
        SocialCubit.get(context).getStories();
      });
    }
  }

  String _getStoryTimeString(dynamic timestamp) {
    if (timestamp == null) return '';
    DateTime? time;
    if (timestamp is DateTime) {
      time = timestamp;
    } else if (timestamp is String) {
      time = DateTime.tryParse(timestamp);
    } else if (timestamp is Timestamp) {
      time = (timestamp as Timestamp).toDate();
    }
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final stories = _stories;
    if (stories.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('لا يوجد استوري', style: TextStyle(color: Colors.black))),
      );
    }
    final currentStory = stories[_currentIndex];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // محتوى الاستوري (نص كبير أو صورة) داخل PageView
            PageView.builder(
              controller: _pageController,
              itemCount: stories.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final story = stories[index];
                return Center(
                  child: story['text'] != null && story['text'].toString().isNotEmpty
                      ? Text(
                          story['text'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : story['imageUrl'] != null && story['imageUrl'].toString().isNotEmpty
                          ? Image.network(story['imageUrl'], fit: BoxFit.contain)
                          : SizedBox.shrink(),
                );
              },
            ),
            // Header: سهم رجوع، صورة واسم ووقت، زر حذف
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // سهم الرجوع
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  // صورة المستخدم
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.userImage),
                  ),
                  SizedBox(width: 10),
                  // اسم المستخدم ووقت الرفع
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (currentStory['timestamp'] != null)
                        Text(
                          _getStoryTimeString(currentStory['timestamp']),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                  Spacer(),
                  // زر الحذف
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: _deleteCurrentStory,
                  ),
                ],
              ),
            ),
            // Indicator
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(stories.length, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 3),
                    width: _currentIndex == index ? 30 : 10,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentIndex == index ? Colors.black : Colors.black26,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 