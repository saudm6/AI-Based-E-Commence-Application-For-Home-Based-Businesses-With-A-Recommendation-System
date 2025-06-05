import 'package:flutter/material.dart';
import '../seller/analytics_seller_page.dart';
import '../seller/home_seller.dart';
import '../seller/settings_seller.dart';

class DashboardSeller extends StatefulWidget {
  const DashboardSeller({super.key});

  @override
  State<DashboardSeller> createState() => _DashboardSellerState();
}

class _DashboardSellerState extends State<DashboardSeller> {
  int _currentIndex = 0;

  // List of pages
  final List<Widget> _pages = [
    HomeSeller(),
    AnalyticsSellerPage(),
    SettingsSeller(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
