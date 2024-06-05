import 'package:chatapp/Auth/auth.dart';
import 'package:chatapp/pages/Calls/call.dart';

import 'package:chatapp/pages/Profile/profile.dart';
import 'package:chatapp/pages/Welcome/Homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import '../pages/GroupChat/group_page.dart';


class BottomMenu extends StatefulWidget {
  @override
  _BottomMenuState createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  int _selectedIndex = 0;
  PageController _pageController = PageController();

  int _index = 0;
  final screens = [
    const HomeScreen(),
    Calls(),
    ProfileScreen(user: APIs.me)

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: screens[_index],

        bottomNavigationBar: Container(
          height: 105,
          child: BottomNavigationBar(
              currentIndex: _index,
              onTap: (value) {
                setState(() {
                  _index = value;
                });
              },

              // backgroundColor: Color.fromARGB(255, 246, 245, 245),
              backgroundColor: Colors.white,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Boxicons.bx_home_circle),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.call),
                  label: 'Calls ',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Boxicons.bxs_user),
                  label: 'Profile',
                ),
                
              ]),
        ));

  }


}
