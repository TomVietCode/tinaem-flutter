import 'package:flutter/material.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../components/persistent_tab_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/match/match.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/setting/settingPage.dart';
import '../screens/home/other_profile_details_screen.dart';

class AppRoutes {
  // Define route names as constants for better access
  static const String signIn = '/';
  static const String signUp = '/sign-up';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String match = '/match';
  static const String chatList = '/chat_list';
  static const String chat = '/chat';
  static const String otherProfileDetails = '/other_profile_details_screen';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> routes = {
    signIn: (context) => const SignInScreen(),
    signUp: (context) => const SignUpScreen(),
    home: (context) => const PersistentTabScreen(),
    profile: (context) => const ProfileScreen(),
    match: (context) => const MatchScreen(),
    chatList: (context) => const ChatListScreen(),
    chat: (context) => const ChatScreen(),
    settings: (context) => const SettingsScreen(),
    otherProfileDetails: (context) {
      // Extract arguments from the navigator
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final user = args?['user'];
      if (user == null) {
        // Handle the case where user is null (optional, depends on your app logic)
        return const Scaffold(body: Center(child: Text('User data not provided')));
      }
      return OtherProfileDetailsScreen(user: user); // Pass the user to the screen
    },
  };
}