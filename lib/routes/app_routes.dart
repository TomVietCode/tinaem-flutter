import 'package:flutter/material.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SignInScreen(),
    '/sign-up': (context) => const SignUpScreen(),
    '/home': (context) => const HomeScreen(),
    '/profile': (context) => const ProfileScreen(),
  };
}
