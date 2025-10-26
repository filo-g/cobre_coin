import 'package:flutter/material.dart';
import 'package:cobre_coin/main.dart';
import 'package:cobre_coin/utils/supabase_utils.dart';

import 'login.dart';
import 'register.dart';

class SplashRoute extends StatefulWidget {
  const SplashRoute({super.key});

  @override
  State<SplashRoute> createState() => _SplashRouteState();
}

class _SplashRouteState extends State<SplashRoute> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final session = SupabaseUtils.getCurrentSession();
    
    // some delay for the loading to appear. is this what they call *sauce*?
    await Future.delayed(const Duration(milliseconds: 300));

    if (session != null) {  // LOGIN PAGE

      // TODO: ask for pin/biometrics to unlock instead of HomeScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );

    } else {  // REGISTER PAGE

      // TODO: ask for register instead of LoginRoute
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RegisterRoute()),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}