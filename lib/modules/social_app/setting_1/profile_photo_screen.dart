import 'package:flutter/material.dart';

class ProfilePhotoScreen extends StatelessWidget {
  const ProfilePhotoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Profile photo', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 24.0, left: 8.0, right: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  _buildItem(context, 'Everyone'),
                  Divider(height: 1, thickness: 1, color: Colors.grey[400]),
                  _buildItem(context, 'Nobody'),
                  Divider(height: 1, thickness: 1, color: Colors.grey[400]),
                  _buildItem(context, 'Same as last seen'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, String title, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 8),
      tileColor: Colors.transparent,
      dense: true,
      minVerticalPadding: 0,
    );
  }
} 