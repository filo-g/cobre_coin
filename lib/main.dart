import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'routes/welcome.dart';
import 'routes/send.dart';
import 'routes/fantasy.dart';
import 'routes/stats.dart';

Future<void> main() async {
import 'routes/fantasy.dart';
import 'routes/stats.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
import 'routes/stats.dart';

  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CobreCoin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFC96000),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String _user = 'Test';
  int _currentIndex = 0;

  final List<Widget> _views = const [
    WelcomeRoute(),
    SendRoute(),
    FantasyRoute(),
    StatsRoute(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Hello $_user!'),
      ),

      body: _views[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.control_point_duplicate),
            label: 'Send',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.recent_actors),
            label: 'Fantasy',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
