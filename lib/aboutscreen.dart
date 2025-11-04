import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
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
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[700],
                backgroundImage: avatarImage,
                child: avatarImage == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
              ),
              const SizedBox(height: 20),

              // User name label
              const Text(
                'User name :',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),

              // User email label
              const Text(
                'User email :',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 40),

              // App version title
              const Text(
                'App version',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),

              // App version text
              const Text(
                'Diary version 1.1. (beta)',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 50),

              // Log out button (centered)
              ElevatedButton(
                onPressed: () {
                  // TODO: Add logout logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 20,
                  ),
                ),
                child: const Text(
                  'log out',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
