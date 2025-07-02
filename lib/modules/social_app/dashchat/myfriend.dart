import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'chatbot.dart';
import 'dart:convert';

class MyFriend extends StatefulWidget {
  @override
  _MyFriendState createState() => _MyFriendState();
}

class _MyFriendState extends State<MyFriend> {
  late ChatUser user;
  late List<ChatMessage> messages;
  List<Map<String, String>> chatHistory = [
    {
      'role': 'system',
      'content': '''
أنت مساعد ذكي.
- إذا كانت رسالة المستخدم بالعربية، أجب بالعربية فقط.
- إذا كانت رسالة المستخدم بالإنجليزية، أجب بالإنجليزية فقط.
- لا تخلط بين اللغتين في نفس الرد.
- التزم بسياق المحادثة ولا تغير الموضوع إلا إذا طلب المستخدم ذلك صراحة.
'''
    },
  ];

  @override
  void initState() {
    super.initState();
    user = ChatUser(
      id: '1',
      firstName: 'Charles',
      lastName: 'Leclerc',
    );
    messages = <ChatMessage>[
      ChatMessage(
        text: 'Hey!',
        user: user,
        createdAt: DateTime.now(),
      ),
    ];
    chatHistory.add({'role': 'user', 'content': 'Hey!'});
    chatHistory.add({'role': 'assistant', 'content': 'مرحبًا! كيف يمكنني مساعدتك؟'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Row(
                          children: [
                            Image.asset(
                              'assets/images/ai icon.png',
                              width: 40,
                              height: 40,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Myfriend',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
      ),
      body: DashChat(
        currentUser: user,
        onSend: (ChatMessage m) async {
          setState(() {
            messages.insert(0, m);
          });
          // كشف لغة الرسالة
          bool isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(m.text);
          if (isArabic) {
            chatHistory.add({'role': 'system', 'content': 'أجب بالعربية فقط.'});
          } else {
            chatHistory.add({'role': 'system', 'content': 'Reply in English only.'});
          }
          chatHistory.add({'role': 'user', 'content': m.text});
          final botReply = await askChatbot(chatHistory);
          String decodedReply;
          try {
            List<int> bytes = latin1.encode(botReply);
            decodedReply = utf8.decode(bytes);
          } catch (e) {
            decodedReply = botReply;
          }
          chatHistory.add({'role': 'assistant', 'content': decodedReply});
          final botMessage = ChatMessage(
            text: decodedReply,
            user: ChatUser(id: 'bot', firstName: 'MyFriend'),
            createdAt: DateTime.now(),
          );
          setState(() {
            messages.insert(0, botMessage);
          });
        },
        messages: messages,
      ),
    );
  }
}