import 'package:flutter/material.dart';
import 'login_screen.dart.dart';
import 'register_screen.dart';
import 'forgotpasswordscreen.dart';
import 'resetpasswordscreen.dart';
import 'main_navigation_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Auth Flow',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot': (context) => const ForgotPasswordScreen(),
        '/reset': (context) => const ResetPasswordScreen(),

        // 👇 Instead of HomeScreen directly, use MainNavigationScreen
        '/diary': (context) => const MainNavigationScreen(),
      },
    );
  }
}
