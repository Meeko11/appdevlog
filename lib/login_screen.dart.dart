import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/main_navigation_screen.dart'; // ✅ use the navigation screen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  File? _imageFile;
  Uint8List? _webImageBytes;

  @override
  void initState() {
    super.initState();
    _loadSavedPhoto();
  }

  Future<void> _loadSavedPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    if (kIsWeb) {
      final b64 = prefs.getString('user_photo_base64');
      if (b64 != null) {
        try {
          final bytes = base64Decode(b64);
          if (mounted) setState(() => _webImageBytes = bytes);
        } catch (_) {
          await prefs.remove('user_photo_base64');
        }
      }
      return;
    }

    final path = prefs.getString('user_photo');
    if (path != null && mounted) {
      final f = File(path);
      if (await f.exists()) {
        setState(() => _imageFile = f);
      } else {
        await prefs.remove('user_photo');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider? avatarImage = kIsWeb
        ? (_webImageBytes != null ? MemoryImage(_webImageBytes!) : null)
        : (_imageFile != null ? FileImage(_imageFile!) : null);

    return Scaffold(
      backgroundColor: const Color(0xFF063851),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[700],
                  backgroundImage: avatarImage,
                  child: avatarImage == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
                ),
                const SizedBox(height: 16),
                Text(
                  "Let's get started",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey[300],
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 30),

                // Username
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Username:',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.transparent,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Colors.lightBlueAccent),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),

                // Password
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password:',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.transparent,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Colors.lightBlueAccent),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 30),

                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainNavigationScreen(), // ✅ nav bar
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Log in"),
                  ),
                ),
                const SizedBox(height: 15),

                // Register button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Register"),
                  ),
                ),
                const SizedBox(height: 15),

                // Forgot password button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.lightBlueAccent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Colors.lightBlueAccent),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Forgot Password?"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
