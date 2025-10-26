import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:phone_form_field/phone_form_field.dart';

import 'routes/splash.dart';
import 'routes/account.dart';
import 'routes/welcome.dart';
import 'routes/send.dart';
import 'routes/fantasy.dart';
import 'routes/stats.dart';

import 'utils/supabase_utils.dart';
import 'utils/show_snack_bar.dart';
import 'utils/phone_form_field.dart';

Future<void> main() async {
  usePathUrlStrategy();

  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_PUBLISHABLE'] ?? '',
  );
  runApp(const MyApp());
}

final supabase = SupabaseUtils.getInstance(); 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: PhoneFieldLocalization.delegates,
      supportedLocales: PhoneFieldView.supportedLocales,
      locale: const Locale('es'),
      title: 'CobreCoin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFC96000),
          brightness: Brightness.dark,
        ),
      ),
      home: SplashRoute(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _displayName;
  String? _username;
  var _loading = true;
  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });
    try {
      final data = await SupabaseUtils.getUserData();
      _displayName = (data?['display_name'] ?? '') as String;
      _username = (data?['username'] ?? '') as String;
    } on PostgrestException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

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
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello $_displayName!',
              style: const TextStyle(
                fontSize: 20, // main title size
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '@$_username',
              style: TextStyle(
                fontSize: 14, // smaller subtitle
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), // subtle color
              ),
            ),
          ],
        ),
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
