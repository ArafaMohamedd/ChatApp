import 'package:flutter/material.dart';
import 'about_screen.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  String onlineValue = 'Everyone';
  String profilePhotoValue = 'Everyone';
  String aboutValue = 'Everyone';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('privacy', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          _buildPopupItem(context, 'Online', onlineValue, (value) {
            setState(() {
              onlineValue = value;
            });
          }),
          Divider(height: 1, thickness: 1, color: Colors.grey),
          _buildPopupItem(context, 'Profile photo', profilePhotoValue, (value) {
            setState(() {
              profilePhotoValue = value;
            });
          }),
          Divider(height: 1, thickness: 1, color: Colors.grey),
          _buildPopupItem(context, 'About', aboutValue, (value) {
            setState(() {
              aboutValue = value;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildPopupItem(BuildContext context, String title, String selectedValue, ValueChanged<String> onSelected) {
    return Container(
      color: Colors.grey[200],
      child: ListTile(
        title: Text(title),
        trailing: PopupMenuButton<String>(
          onSelected: onSelected,
          itemBuilder: (context) => [
            PopupMenuItem(value: 'Everyone', child: Text('Everyone')),
            PopupMenuItem(value: 'Nobody', child: Text('Nobody')),
            PopupMenuItem(value: 'My contacts', child: Text('My contacts')),
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(selectedValue, style: TextStyle(color: Colors.grey)),
              Icon(Icons.arrow_drop_down, color: Colors.grey, size: 22),
            ],
          ),
        ),
      ),
    );
  }
} 