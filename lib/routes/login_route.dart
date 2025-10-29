import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cobre_coin/main.dart';
import 'package:cobre_coin/utils/show_snack_bar.dart';

import 'splash_route.dart';

class LoginRoute extends StatefulWidget {
  const LoginRoute({super.key});

  @override
  State<LoginRoute> createState() => _LoginRouteState();
}
class _LoginRouteState extends State<LoginRoute> {
  bool _isLoading = false;
  bool _redirecting = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final StreamSubscription<AuthState> _authStateSubscription;

  Future<void> _signInWithPassword() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) return;

      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final Session? session = res.session;
      final User? user = res.user;

      if (mounted) {
        if (session != null && user != null) {
          context.showSnackBar('Logged in successfully!');
        } else {
          context.showSnackBar('Something went wrong.');
        }
      }
      _emailController.clear();
      _passwordController.clear();

    } on AuthException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    _authStateSubscription = supabase.auth.onAuthStateChange.listen(
      (data) {
        if (_redirecting) return;
        final session = data.session;
        if (mounted && session != null) {
          _redirecting = true;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SplashRoute()),
          );
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
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Styles
    var decorationBorder = OutlineInputBorder(borderRadius: BorderRadius.circular(50));
    var decorationContentPadding = const EdgeInsets.all(12);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          const Text('Welcome back to the CobreCoin Internal Bank!'),
          const SizedBox(height: 18),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: decorationBorder,
              contentPadding: decorationContentPadding,
            ),
            autofillHints: [
              AutofillHints.username,
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              border: decorationBorder,
              contentPadding: decorationContentPadding,
            ),
            autofillHints: [
              AutofillHints.password,
            ],
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _isLoading ? null : _signInWithPassword,
            child: Text(_isLoading ? 'Logging in...' : 'Log in'),
          ),
        ],
      ),
    );
  }
}