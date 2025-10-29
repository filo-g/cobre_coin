import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cobre_coin/utils/show_snack_bar.dart';
import 'package:cobre_coin/utils/supabase_utils.dart';

class ForgotPasswordRoute extends StatefulWidget {
  const ForgotPasswordRoute({super.key});

  @override
  State<ForgotPasswordRoute> createState() => _ForgotPasswordRouteState();
}
class _ForgotPasswordRouteState extends State<ForgotPasswordRoute> {
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _supabase = SupabaseUtils.getInstance();

  Future<void> _sendReset() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();

      if (email.isEmpty) return;

      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 
          kIsWeb ? null : 'io.supabase.cobrecoin://reset-password-callback/',
      );

      if (mounted) {
        context.showSnackBar('Password reset email sent to $email');
      }
      _emailController.clear();

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
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Styles
    var decorationBorder = OutlineInputBorder(borderRadius: BorderRadius.circular(50));
    var decorationContentPadding = const EdgeInsets.all(12);

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          const Text('Let\'s send you a password reset'),
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
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _isLoading ? null : _sendReset,
            child: Text(_isLoading ? 'Sending...' : 'Send'),
          ),
        ],
      ),
    );
  }
}