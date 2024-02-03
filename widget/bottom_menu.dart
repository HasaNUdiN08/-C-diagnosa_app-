
import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';

class BottomMenuBar extends StatelessWidget {
  final int currentIndex;

  BottomMenuBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(), // Pass user information here
            ),
          );
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: currentIndex == 0 ? Colors.blue.shade900 : null),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: currentIndex == 1 ? Colors.blue.shade900 : null),
          label: 'Profile',
        ),
      ],
    );
  }
}