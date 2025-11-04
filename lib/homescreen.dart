import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isExpanded = false;
  bool _isWeatherExpanded = false;

  final List<Map<String, dynamic>> _entries = [];

  // Weather variables
  String _temperature = "--";
  String _condition = "Loading...";
  String _feelsLike = "--";
  String _wind = "--";

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      // Example: Manila lat/lon (you can replace with geolocator later)
      const double lat = 14.5995;
      const double lon = 120.9842;

      final url = Uri.parse(
          "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          final weather = data['current_weather'];
          _temperature = "${weather['temperature']}°C";
          _condition = "Condition code: ${weather['weathercode']}";
          _feelsLike = "${weather['temperature'] + 2}°C"; // fake feels like
          _wind = "${weather['windspeed']} km/h";
        });
      } else {
        setState(() {
          _condition = "Error fetching weather";
        });
      }
    } catch (e) {
      setState(() {
        _condition = "Failed to load weather";
      });
    }
  }

  void _saveEntry() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _entries.insert(0, {
        'title': 'diary ${DateTime.now().toLocal().toString().split(' ')[0]}',
        'content': _controller.text.trim(),
        'expanded': false,
      });
      _controller.clear();
      _isExpanded = false;
    });
  }

  void _toggleExpand(int index) {
    setState(() {
      _entries[index]['expanded'] = !_entries[index]['expanded'];
    });
  }

  void _deleteEntry(int index) {
    setState(() {
      _entries.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF063851),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hello User',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),

            // Diary Input
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade700,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      maxLines: _isExpanded ? 10 : 1,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'write something',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                      readOnly: !_isExpanded,
                      onTap: () {
                        setState(() => _isExpanded = true);
                      },
                    ),
                    if (_isExpanded)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: _saveEntry,
                            icon: const Icon(Icons.save_alt, color: Colors.white),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Weather Card (Expandable with API Data)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isWeatherExpanded = !_isWeatherExpanded;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade600,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Today's Weather",
                                style: const TextStyle(color: Colors.purpleAccent)),
                            Text(DateTime.now().toLocal().toString().split(" ")[0],
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                        const Icon(Icons.cloud, color: Colors.blueAccent),
                      ],
                    ),
                    if (_isWeatherExpanded) ...[
                      const SizedBox(height: 12),
                      Text("Temperature: $_temperature",
                          style: const TextStyle(color: Colors.white)),
                      Text("Condition: $_condition",
                          style: const TextStyle(color: Colors.white)),
                      Text("Feels like: $_feelsLike",
                          style: const TextStyle(color: Colors.white)),
                      Text("Wind: $_wind",
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Diary Entries List
            Expanded(
              child: ListView.builder(
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) => _deleteEntry(index),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: GestureDetector(
                      onTap: () => _toggleExpand(index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade500,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry['title'],
                              style: const TextStyle(color: Colors.pinkAccent, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry['expanded']
                                  ? entry['content']
                                  : entry['content'].length > 40
                                      ? '${entry['content'].substring(0, 40)}...'
                                      : entry['content'],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
