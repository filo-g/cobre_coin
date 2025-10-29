import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cobre_coin/utils/show_snack_bar.dart';
import 'package:cobre_coin/utils/supabase_utils.dart';

import 'login_route.dart';

class ResetPasswordRoute extends StatefulWidget {
  const ResetPasswordRoute({super.key});

  @override
  State<ResetPasswordRoute> createState() => _ResetPasswordRouteState();
}
class _ResetPasswordRouteState extends State<ResetPasswordRoute> {
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _sendReset() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (_formKey.currentState!.validate()) {
        final password = _passwordController.text.trim();
        final supabase = SupabaseUtils.getInstance();
        final res = await supabase.auth.updateUser(
          UserAttributes(
            password: password,
          ),
        );

        if (mounted) {
          if (res.user != null) {
            context.showSnackBar('Password updated, please log back in.');
            await supabase.auth.signOut();
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginRoute()),
              );
            } 
          } else {
            context.showSnackBar('We failed trying to update your password.', isError: true);
          }
        }
        _passwordController.clear();
        _confirmPasswordController.clear();
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
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Styles
    var decorationBorder = OutlineInputBorder(borderRadius: BorderRadius.circular(50));
    var decorationContentPadding = const EdgeInsets.all(12);

    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          const Text('Let\'s reset your password'),
          const SizedBox(height: 18),
          Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 8),
                AutofillGroup(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: decorationBorder,
                          contentPadding: decorationContentPadding,
                        ),
                        autofillHints: [
                          AutofillHints.newPassword,
                          AutofillHints.password,
                        ],
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          final rules = {
                            r'.{8,}':
                              'Password must be at least 8 characters',
                            r'[a-z]':
                              'Password must contain at least one lowercase letter',
                            r'[A-Z]':
                              'Password must contain at least one uppercase letter',
                            r'[0-9]':
                              'Password must contain at least one number',
                            r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:\",.<>\/?\\|`~]':
                              'Password must contain at least one special character',
                          };

                          for (final entry in rules.entries) {
                            if (!RegExp(entry.key).hasMatch(value)) {
                              return entry.value;
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Repeat password',
                          border: decorationBorder,
                          contentPadding: decorationContentPadding,
                        ),
                        autofillHints: [
                          AutofillHints.newPassword,
                          AutofillHints.password,
                        ],
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  )
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _isLoading ? null : _sendReset,
            child: Text(_isLoading ? 'Saving...' : 'Reset your password'),
          ),
        ],
      ),
    );
  }
}