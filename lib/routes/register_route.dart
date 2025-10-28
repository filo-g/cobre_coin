import 'dart:async';

import 'package:cobre_coin/routes/login_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:cobre_coin/main.dart';
import 'package:cobre_coin/utils/show_snack_bar.dart';
import 'package:cobre_coin/utils/phone_form_field.dart';

class RegisterRoute extends StatefulWidget {
  const RegisterRoute({super.key});
  
  @override
  State<RegisterRoute> createState() => _RegisterRouteState();
}

class _RegisterRouteState extends State<RegisterRoute> {
  bool _isLoading = false;
  bool _redirecting = false;
  DateTime _selectedDate = DateTime.now();
  String? _selectedDateFormatted;
  String? _selectedPronouns;
  
  // Form fields
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _dateController = TextEditingController();
  // Email-related vars
  late final TextEditingController _emailController = TextEditingController();
  late final StreamSubscription<AuthState> _authStateSubscription;
  // Phone-related vars
  late PhoneController _phoneController;
  final FocusNode focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  // Pronouns options
  final List<DropdownMenuItem> pronounsItems = [
    DropdownMenuItem(value: 'he', child: Text('He/him')),
    DropdownMenuItem(value: 'she', child: Text('She/her')),
    DropdownMenuItem(value: 'they', child: Text('They/them')),
  ];
  


  Future<void> _register() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final phoneValue = _phoneController.value;
      
      if (
        _formKey.currentState!.validate() &&
        phoneValue.isValid(type: PhoneNumberType.mobile)
      ) {

        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();
        final username = _usernameController.text.trim();
        final displayName = _displayNameController.text.trim();
        final fullName = _fullNameController.text.trim();
        final phone = "+${phoneValue.countryCode}${phoneValue.nsn}";
        final birthDate = _selectedDateFormatted;
        final pronouns = _selectedPronouns;

        final AuthResponse res = await supabase.auth.signUp(
          email: email,
          password: password,
          data: { // public metadata will be stored in public.users by a function trigger
            'username': username,
            'display_name': displayName,
            'full_name': fullName,
            'pronouns': pronouns,
            'birth_date': birthDate,
            'phone': phone, // storing it in metadata to avoid OTP
          },
          emailRedirectTo:
              kIsWeb ? null : 'io.supabase.cobrecoin://register-callback/',
        );
        // final Session? session = res.session;
        final User? user = res.user;

        if (user != null) {
        // TODO: do whatever is needed with session and user to wait for aproval
        }

      }

    } on AuthException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('$error', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedDateFormatted = '''
          ${picked.toLocal().year.toString().padLeft(4, '0')}-
          ${picked.month.toString().padLeft(2, '0')}-
          ${picked.day.toString().padLeft(2, '0')}
        '''.replaceAll(RegExp(r'\s+'), ''); // format like yyyy-mm-dd
        _dateController.text = '''
          ${picked.day.toString().padLeft(2, '0')}/
          ${picked.month.toString().padLeft(2, '0')}/
          ${picked.year}
        '''.replaceAll(RegExp(r'\s+'), ''); // format like dd/mm/yyyy
      });
    }
  }

  @override
  void initState() {
    _phoneController = PhoneController();
    _phoneController.addListener(() => setState(() {}));
    
    // TODO: Check this as is a copy-paste from login.dart
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
    // Styles
    var decorationBorder = OutlineInputBorder(borderRadius: BorderRadius.circular(50));
    var decorationContentPadding = const EdgeInsets.all(12);

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          const Text('Let\'s open your new CobreCoin Internal Bank Account'),
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
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: decorationBorder,
                          contentPadding: decorationContentPadding,
                        ),
                        autofillHints: [
                          AutofillHints.newUsername,
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
                const SizedBox(height: 24),
                const Text('Personal data'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'usuario123',
                    helperText: 'Your unique login name.',
                    border: decorationBorder,
                    contentPadding: decorationContentPadding,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    labelText: 'Display Name',
                    hintText: 'Tu mote',
                    helperText: 'The name we will show to other users.',
                    border: decorationBorder,
                    contentPadding: decorationContentPadding,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Nombre y apellidos',
                    helperText: 'Your full name. Only you and CobreCo. will see this.',
                    border: decorationBorder,
                    contentPadding: decorationContentPadding,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField(
                  initialValue: _selectedPronouns,
                  decoration: InputDecoration(
                    labelText: 'Pronouns',
                    helperText: 'The pronouns you are more confortable with.',
                    border: decorationBorder,
                    contentPadding: decorationContentPadding,
                  ),
                  items: pronounsItems,
                  onChanged: (val) => setState(() {
                    _selectedPronouns = val;
                  }),
                ),
                const SizedBox(height: 16),
                PhoneFieldView(
                  controller: _phoneController,
                  focusNode: focusNode,
                  selectorNavigator:
                    CountrySelectorNavigator.draggableBottomSheet(
                      favorites: [IsoCode.ES],
                    ),
                  withLabel: false,
                  withDescription: true,
                  outlineBorder: true,
                  isCountryButtonPersistant: true,
                  mobileOnly: false,
                  locale: Locale('es'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _selectDate,
                  decoration: InputDecoration(
                    labelText: 'Birth date',
                    helperText: 'Your birth date. You may encounter a gift on your birthday ;)',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: decorationBorder,
                    contentPadding: decorationContentPadding,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _isLoading ? null : _register,
            child: Text(_isLoading ? 'Sending...' : 'Submit registration'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginRoute()),
              );
            },
            child: const Text('I already have an account'),
          ),
        ],
      ),
    );
  }
}