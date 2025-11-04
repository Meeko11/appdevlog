import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  File? _imageFile;
  Uint8List? _webImageBytes;
  final ImagePicker _picker = ImagePicker();

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
    } else {
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
  }

  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        imageQuality: 85,
      );
      if (picked == null) return;

      final prefs = await SharedPreferences.getInstance();

      if (kIsWeb) {
        // Read bytes and store as base64 in prefs
        final bytes = await picked.readAsBytes();
        final b64 = base64Encode(bytes);
        await prefs.setString('user_photo_base64', b64);
        // remove native path if present
        await prefs.remove('user_photo');
        setState(() {
          _webImageBytes = bytes;
          _imageFile = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo saved (web)')),
          );
        }
        print('Picked (web) size: ${bytes.length} bytes');
        return;
      }

      // Mobile/desktop: save to app documents
      final appDir = await getApplicationDocumentsDirectory();
      final ext = picked.path.split('.').last;
      final fileName = 'user_photo_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final savedPath = '${appDir.path}/$fileName';

      // Use XFile.saveTo to handle content URIs on Android
      await picked.saveTo(savedPath);
      final savedFile = File(savedPath);

      // debug
      print('Picked file: ${picked.path}');
      print('Saved file: ${savedFile.path}');

      await prefs.setString('user_photo', savedFile.path);
      await prefs.remove('user_photo_base64');

      setState(() {
        _imageFile = savedFile;
        _webImageBytes = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo saved')),
        );
      }
    } catch (e) {
      print('Error picking/saving image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save photo: $e')),
        );
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Go back to login
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Register Icon (tappable to pick image)
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[700],
                    backgroundImage: avatarImage,
                    child: avatarImage == null
                        ? const Icon(Icons.person_add, size: 50, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.grey[300],
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 30),

                // Email
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email Address:',
                    labelStyle: const TextStyle(color: Colors.white70),
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

                // Confirm Password
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password:',
                    labelStyle: const TextStyle(color: Colors.white70),
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

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Sign Up"),
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
