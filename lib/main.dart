import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:phone_form_field/phone_form_field.dart';

import 'routes/splash_route.dart';
import 'views/account_view.dart';
import 'views/welcome_view.dart';
import 'views/send_view.dart';
import 'views/fantasy_view.dart';
import 'views/stats_view.dart';
import 'views/admin/users_view.dart';

import 'utils/supabase_auth_listener.dart';
import 'utils/supabase_utils.dart';
import 'utils/show_snack_bar.dart';
import 'utils/phone_form_field.dart';

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_PUBLISHABLE'] ?? '',
  );
  runApp(const MyApp());
}

final supabase = SupabaseUtils.getInstance();
final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StreamSubscription _streamSubscription;
  
  @override
  void initState() {
    super.initState();
    _streamSubscription = supabaseAuthListener(navigatorKey);
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

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
      navigatorKey: navigatorKey,
      home: SplashRoute(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var _loading = true;

  String? _displayName;
  String? _username;
  bool _isAdmin = false;

  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });
    try {
      _displayName = await SupabaseUtils.getUserField('display_name');
      _username = await SupabaseUtils.getUserField('username');
      _isAdmin = await SupabaseUtils.getUserRole() == 'admin';

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

  final List<Widget> _userViews = const [
    WelcomeView(),
    SendView(),
    FantasyView(),
    StatsView(),
  ];
  final List<Widget> _adminViews = const [
    WelcomeView(),
    UsersView(),
  ];

  BottomNavigationBar _userNavigationBar(BuildContext context) => BottomNavigationBar(
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
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
  );
  BottomNavigationBar _adminNavigationBar(BuildContext context) => BottomNavigationBar(
  currentIndex: _currentIndex,
  type: BottomNavigationBarType.fixed,
  onTap: _onTabTapped,
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),

    BottomNavigationBarItem(
      icon: Icon(Icons.manage_accounts),
      label: 'Manage users',
    ),
  ],
  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
);

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

      body:
        _isAdmin ?
        _adminViews[_currentIndex] :
        _userViews[_currentIndex] ,

      bottomNavigationBar:
        _isAdmin ?
        _adminNavigationBar(context) :
        _userNavigationBar(context) ,
    );
  }
}
