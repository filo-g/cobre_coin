import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cobre_coin/main.dart';
import 'package:cobre_coin/utils/supabase_utils.dart';
import 'package:cobre_coin/utils/show_snack_bar.dart';

import 'register_route.dart';
import 'approval_route.dart';
import 'reset_password_route.dart';
// import 'login_route.dart';

class SplashRoute extends StatefulWidget {
  const SplashRoute({super.key});

  @override
  State<SplashRoute> createState() => _SplashRouteState();
}

class _SplashRouteState extends State<SplashRoute> {
  late final StreamSubscription _authStateSubscription;

  @override
  void initState() {
    // Supabase link redirects
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      switch (event) {
        case AuthChangeEvent.passwordRecovery:
          _goTo(ResetPasswordRoute());
          break;
        default:
      }
    },
    onError: (error) {
      if (mounted) {
        if (error is AuthException) {
          context.showSnackBar(error.message, isError: true);
        } else {
          context.showSnackBar('Unexpected error occurred', isError: true);
        }
      }
    },);

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
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
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