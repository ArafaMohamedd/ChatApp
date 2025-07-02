import 'package:flutter/material.dart';

class ChatsScreenSettings extends StatelessWidget {
  const ChatsScreenSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Chats', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          _buildItem(context, 'chat theme'),
          Divider(height: 1, thickness: 1, color: Colors.grey),
          _buildItem(context, 'Wallpaper'),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String title, {VoidCallback? onTap}) {
    return Container(
      color: Colors.grey[200],
      child: ListTile(
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: onTap,
      ),
    );
  }
} 