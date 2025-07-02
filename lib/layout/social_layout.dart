import 'package:chatnew/core/utils/components.dart';
import 'package:chatnew/core/utils/constants.dart';
import 'package:chatnew/layout/cubit/cubit.dart';
import 'package:chatnew/layout/cubit/states.dart';
import 'package:chatnew/modules/social_app/dashchat/myfriend.dart';
import 'package:chatnew/modules/social_app/social_login/toast.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/utils/constants.dart';

class SocialLayout extends StatefulWidget {
  const SocialLayout({Key? key}) : super(key: key);

  @override
  State<SocialLayout> createState() => _SocialLayoutState();
}

class _SocialLayoutState extends State<SocialLayout> {
  int selectedFilter = 0;
  bool showSearchBar = false;
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = SocialCubit.get(context);
        Color getIconColor(int index) {
          return cubit.currentIndex == index ? Colors.white : KMainColor;
        }
        return Scaffold(
          appBar: AppBar(
            leading:  IconButton(
              icon: Image.asset(
                'assets/images/icon indicator.png',
                height: 25,
              ),
              onPressed: (){},
            ),
            titleSpacing: 90,
            title: Text(
              cubit.titles[cubit.currentIndex],
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              if (cubit.currentIndex == 0)
              IconButton(
                  icon: Icon(Icons.notifications_active_outlined),
                 color: KMainColor,
                 onPressed: (){},
              ),
              
              if (cubit.currentIndex == 0)
                IconButton(
                  icon: Icon(Icons.search),
                  color: KMainColor,
                  onPressed: () {
                    setState(() {
                      showSearchBar = !showSearchBar;
                      if (!showSearchBar) searchController.clear();
                    });
                  },
                ),
            ],
          ),
          body: Column(
            children: [
              if (cubit.currentIndex == 0 && showSearchBar)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.black54),
                        hintText: 'Search',
                      ),
                    ),
                  ),
                ),
              if (cubit.currentIndex == 0)
                Column(
                  children: [
                    Divider(height: 1),
                    InkWell(
                      onTap: () 
                      {
                  
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => MyFriend()),
                   );
                 
                },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        child: Row(
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
                    ),
                    Divider(height: 1),
                  ],
                ),
              if (cubit.currentIndex == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(3, (index) {
                      final filters = ['All', 'Unread', 'Group'];
                      final isSelected = selectedFilter == index;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedFilter = index;
                            });
                            // هنا يمكنك إضافة كود الفلترة حسب الزر المختار
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                            decoration: BoxDecoration(
                              color: isSelected ? Color(0xFF3B1E77) : Colors.grey[300],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              filters[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              // باقي الصفحة الرئيسية
              Expanded(child: cubit.screens[cubit.currentIndex]),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: cubit.currentIndex,
            onTap: (index) {
              cubit.changeBottomNav(index);
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: null,
            unselectedItemColor: null,
            backgroundColor: Colors.grey,
            elevation: 20.0,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              BottomNavigationBarItem(
                icon: Opacity(
                  opacity: cubit.currentIndex == 0 ? 0.5 : 1.0,
                  child: Image.asset(
                    'assets/images/icon chat.png',
                    width: 50,
                    height: 50,
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Opacity(
                  opacity: cubit.currentIndex == 1 ? 0.5 : 1.0,
                  child: Image.asset(
                    'assets/images/icon status.png',
                    width: 50,
                    height: 50,
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Opacity(
                  opacity: cubit.currentIndex == 2 ? 0.5 : 1.0,
                  child: Image.asset(
                    'assets/images/icon setting.png',
                    width: 50,
                    height: 50,
                  ),
                ),
                label: '',
              ),
            ],
          ),
        );
      },
    );
  }
}



