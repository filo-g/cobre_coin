import 'package:flutter/material.dart';
import 'package:cobre_coin/main.dart';
import 'package:cobre_coin/utils/supabase_utils.dart';

import 'register_route.dart';
import 'approval_route.dart';
// import 'login_route.dart';

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

  void _goTo(Widget page) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<void> _checkSession() async {
    final session = SupabaseUtils.getCurrentSession();
    
    // some delay for the loading to appear. is this what they call *sauce*?
    await Future.delayed(const Duration(milliseconds: 300));

    if (session == null) {
      _goTo(RegisterRoute());
      return;
    }

    final approval = await SupabaseUtils.getUserApproval();
    if (!approval) {
      _goTo(ApprovalRoute());
      return;
    }

    // TODO: ask for pin/biometrics to unlock instead of MainScreen
    _goTo(MainScreen());
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