import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'routes/login.dart';
import 'routes/account.dart';
import 'routes/welcome.dart';
import 'routes/send.dart';
import 'routes/fantasy.dart';
import 'routes/stats.dart';

Future<void> main() async {
  usePathUrlStrategy();

  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_PUBLISHABLE'] ?? '',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

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
      home: supabase.auth.currentSession == null
          ? const LoginRoute()
          : const HomeScreen(),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), // gear icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountRoute()),
              );
            },
          ),
        ],
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
