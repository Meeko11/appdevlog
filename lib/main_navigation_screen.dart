import 'package:flutter/material.dart';
import 'package:flutter_application_1/aboutscreen.dart';
import 'package:flutter_application_1/homescreen.dart';
import 'package:flutter_application_1/time_capsule.dart'; // 👈 Import your capsule screen
import 'package:flutter_svg/flutter_svg.dart'; // add flutter_svg import

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 1; // Start with Home selected

  final List<Widget> _screens = const [
    TimeCapsuleScreen(), // 👈 Capsule screen (first tab)
    HomeScreen(),        // Home screen (middle tab)
    AboutScreen(),       // About screen (last tab)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconTheme(
            data: const IconThemeData(size: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Capsule button
                IconButton(
                  tooltip: "Capsule",
                  icon: SizedBox(
                    width: 30,
                    height: 30,
                    child: SvgPicture.asset(
                      'assets/time_capsule.svg',
                      color: _currentIndex == 0 ? const Color(0xFF063851) : Colors.grey[500],
                      fit: BoxFit.contain,
                    ),
                  ),
                  onPressed: () => setState(() => _currentIndex = 0),
                ),

                // Home button in middle
                IconButton(
                  tooltip: "Home",
                  icon: Icon(
                    Icons.home,
                    color: _currentIndex == 1 ? const Color(0xFF063851) : Colors.grey[500],
                  ),
                  onPressed: () => setState(() => _currentIndex = 1),
                ),

                // About button
                IconButton(
                  tooltip: "About",
                  icon: Icon(
                    Icons.info,
                    color: _currentIndex == 2 ? const Color(0xFF063851) : Colors.grey[500],
                  ),
                  onPressed: () => setState(() => _currentIndex = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
