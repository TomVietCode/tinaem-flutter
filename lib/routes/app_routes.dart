import 'package:flutter/material.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../components/persistent_tab_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/match/match.dart';
import '../screens/chat/chat_list_screen.dart'; // Cập nhật đường dẫn
import '../screens/chat/chat_screen.dart';     // Cập nhật đường dẫn

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SignInScreen(),
    '/sign-up': (context) => const SignUpScreen(),
    '/home': (context) => const PersistentTabScreen(),
    '/profile': (context) => const ProfileScreen(),
    '/match': (context) => const MatchScreen(),
    '/chat_list': (context) => const ChatListScreen(),
    '/chat': (context) => const ChatScreen(),
  };
}