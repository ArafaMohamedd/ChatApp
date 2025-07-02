import 'package:chatnew/core/utils/constants.dart';
import 'package:chatnew/modules/social_app/settings_2/setting_screens2.dart';
import 'package:chatnew/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'privacy_screen.dart';
import 'chats_screen.dart';
import 'package:chatnew/layout/cubit/cubit.dart';

class SettingsScreen1 extends StatelessWidget {
  const SettingsScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Profile Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundImage: (SocialCubit.get(context).userModel?.image != null && SocialCubit.get(context).userModel!.image!.isNotEmpty)
                      ? NetworkImage(SocialCubit.get(context).userModel!.image!)
                      : AssetImage('assets/images/icon chat.png') as ImageProvider,
                ),
                title: Text('Profile Name', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('About'),
                onTap: () {
                  
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => SettingsScreen2()),
                   );
                 
                },
              ),
            ),
          ),
          // Settings List
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildSettingsItem(
                    icon: Icons.lock_outline,
                    text: 'Privacy',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PrivacyScreen()),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.chat_bubble_outline,
                    text: 'chats',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatsScreenSettings()),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.notifications_none,
                    text: 'Notifications',
                    onTap: () {},
                  ),
                  _buildSettingsItem(
                    icon: Icons.person_add_alt,
                    text: 'Invite a friend',
                    onTap: () {},
                  ),
                  // Log out
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text('Log out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      onTap: () {
                        _showLogoutDialog(context);
                      },
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.red, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(text, style: TextStyle(fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SystemNavigator.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold,)),
          ),
        ],
      ),
    );
  }
}
