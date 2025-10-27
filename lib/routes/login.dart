import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:cobre_coin/main.dart';
import 'package:cobre_coin/utils/show_snack_bar.dart';
import 'package:cobre_coin/utils/phone_form_field.dart';

class LoginRoute extends StatefulWidget {
  const LoginRoute({super.key});

  @override
  State<LoginRoute> createState() => _LoginRouteState();
}
class _LoginRouteState extends State<LoginRoute> {
  bool _isLoading = false;
  bool _redirecting = false;
  // Email-related vars
  late final TextEditingController _emailController = TextEditingController();
  late final StreamSubscription<AuthState> _authStateSubscription;
  // Phone-related vars
  late PhoneController _phoneController;
  final FocusNode focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  Future<void> _signIn() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await supabase.auth.signInWithOtp(
        email: _emailController.text.trim(),
        emailRedirectTo:
            kIsWeb ? null : 'io.supabase.cobrecoin://login-callback/',
      );
      if (mounted) {
        context.showSnackBar('Check your email for a login link!');
        _emailController.clear();
      }
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
    _phoneController = PhoneController();
    _phoneController.addListener(() => setState(() {}));
    
    _authStateSubscription = supabase.auth.onAuthStateChange.listen(
      (data) {
        if (_redirecting) return;
        final session = data.session;
        if (mounted && session != null) {
          _redirecting = true;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
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
    _phoneController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          const Text('Sign in via the magic link with your email below'),
          const SizedBox(height: 18),
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                  contentPadding: const EdgeInsets.all(12)),
                ),
                const SizedBox(height: 8),
                PhoneFieldView(
                  controller: _phoneController,
                  focusNode: focusNode,
                  selectorNavigator:
                    CountrySelectorNavigator.draggableBottomSheet(
                      favorites: [IsoCode.ES],
                    ),
                  withLabel: false,
                  withDescription: false,
                  outlineBorder: true,
                  isCountryButtonPersistant: true,
                  mobileOnly: false,
                  locale: Locale('es'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _isLoading ? null : _signIn,
            child: Text(_isLoading ? 'Sending...' : 'Send Magic Link'),
          ),
        ],
      ),
    );
  }
}