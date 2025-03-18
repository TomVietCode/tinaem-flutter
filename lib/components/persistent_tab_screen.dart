import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/match/match.dart';

class PersistentTabScreen extends StatefulWidget {
  const PersistentTabScreen({super.key});

  @override
  State<PersistentTabScreen> createState() => _PersistentTabScreenState();
}

class _PersistentTabScreenState extends State<PersistentTabScreen> {
  int _selectedIndex = 1; // Mặc định là MatchScreen khi quay lại từ HomeScreen

  final List<Widget> _screens = [
    const SafeArea(child: HomeScreen()),
    const SafeArea(child: MatchScreen()),
    const SafeArea(child: ChatListScreen()),
    const SafeArea(child: ProfileScreen()),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex == 0) {
      setState(() {
        _selectedIndex = 1;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: _selectedIndex == 0
            ? null
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: GNav(
                    backgroundColor: Colors.transparent,
                    color: Colors.grey,
                    activeColor: Colors.pink,
                    tabBackgroundColor: Colors.pink.withOpacity(0.1),
                    gap: 8,
                    padding: const EdgeInsets.all(16),
                    tabs: [
                      GButton(
                        icon: CupertinoIcons.home,
                        leading: Image.asset(
                          "assets/tinder_logo.png",
                          width: 24,
                          height: 24,
                        ),
                        text: 'Home',
                      ),
                      GButton(
                        icon: CupertinoIcons.location,
                        text: 'Connection',
                      ),
                      GButton(
                        icon: CupertinoIcons.chat_bubble,
                        text: 'Message',
                      ),
                      GButton(
                        icon: CupertinoIcons.person,
                        text: 'Profile',
                      ),
                    ],
                    selectedIndex: _selectedIndex,
                    onTabChange: _onItemTapped,
                  ),
                ),
              ),
      ),
    );
  }
}