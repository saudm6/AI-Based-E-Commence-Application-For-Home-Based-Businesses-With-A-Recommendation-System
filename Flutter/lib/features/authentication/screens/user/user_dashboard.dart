import 'package:ai_test/features/authentication/screens/user/screens/USER_MAIN_SCREEN.dart';
import 'package:ai_test/features/authentication/screens/user/screens/cart_page_user.dart';
import 'package:ai_test/features/authentication/screens/user/screens/search_page_user.dart';
import 'package:ai_test/features/authentication/screens/user/screens/settings_page_user.dart';
import 'package:flutter/material.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  UserDashboardState createState() => UserDashboardState();
}

class UserDashboardState extends State<UserDashboard> {
  int _currentIndex = 0;

  // List of pages
  final _pages = [
    UserMainScreen(),
    SearchPageUser(),
    CartPageUser(),
    SettingsPageUser(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => setState(() => _currentIndex = i),

          // Bottom Navigation
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home, color: Colors.blue,), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.search, color: Colors.blue,), label: 'Search'),
            const BottomNavigationBarItem(icon: Icon(Icons.shopping_cart, color: Colors.blue,), label: 'Cart'),
            const BottomNavigationBarItem(icon: Icon(Icons.settings, color: Colors.blue,), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}