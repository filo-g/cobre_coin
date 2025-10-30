import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cobre_coin/routes/splash_route.dart';
import 'package:cobre_coin/routes/login_route.dart';
import 'package:cobre_coin/routes/reset_password_route.dart';

import 'show_snack_bar.dart';
import 'supabase_utils.dart';

/// Starts a global listener for Supabase auth redirect events such as password
/// recovery. Uses the MyApp's [navigatorKey] to control the view on redirects.
///
/// Returns a [StreamSubscription].
StreamSubscription<AuthState> supabaseAuthListener(GlobalKey<NavigatorState> navigatorKey) {
  final supabase = SupabaseUtils.getInstance();
  final subscription = supabase.auth.onAuthStateChange.listen(
    (data) {
      final event = data.event;
      final session = data.session;

      switch (event) {
        case AuthChangeEvent.passwordRecovery:
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (_) => const ResetPasswordRoute()),
          );
          break;
        case AuthChangeEvent.signedOut:
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginRoute()),
            (route) => false,
          );
          break;

        default:
          if (session != null) {
            // If in state change there is a session go back to spash to check
            navigatorKey.currentState?.pushReplacement(
              MaterialPageRoute(builder: (_) => const SplashRoute()),
            );
          }
      }

    },
    onError: (error) {
      if (error is AuthException) {
        navigatorKey.currentContext?.showSnackBar(error.message, isError: true);
      } else {
        navigatorKey.currentContext?.showSnackBar('Unexpected error occurred', isError: true);
      }
    },
  );

  return subscription;
}
