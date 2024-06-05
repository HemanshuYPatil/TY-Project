import 'package:chatapp/Auth/auth.dart';
import 'package:chatapp/pages/Bot/BotScreen.dart';
import 'package:chatapp/pages/Bot/ChatBuddyGPT/ChatBuddyGPT.dart';
import 'package:chatapp/pages/GroupChat/grouplists.dart';
import 'package:chatapp/pages/Profile/profile.dart';
import 'package:chatapp/pages/Welcome/Homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../pages/Profile/setting_page.dart';

class BottomBar extends StatefulWidget {

   BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  List<Widget> pages = [
    Container(
      child: const HomeScreen(),
    ),
    Container(
      child: const GroupListChat(),
    ),
    Container(
      child: const BotLists(),
    ),
    Container(
      child: AccountScreen(user: APIs.me,),
    ),
  ];
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: currentIndex,
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          SalomonBottomBarItem(
              icon: const Icon(Boxicons.bx_home), title: const Text('Chats')),
          SalomonBottomBarItem(
              icon: const Icon(Boxicons.bx_group), title: const Text('Groups')),
          SalomonBottomBarItem(
              icon: const Icon(Boxicons.bx_bot), title: const Text('Bot')),

          SalomonBottomBarItem(
              icon: const Icon(Boxicons.bx_user), title: const Text('Settings'))
        ],
      ),
    );
  }
}
