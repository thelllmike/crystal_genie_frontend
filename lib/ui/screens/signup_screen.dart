import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app_router.dart';
import '../../core/services/auth_service.dart';
import '../widgets/glass.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final password = _password.text;
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }
    setState(() => _loading = true);
    try {
      final signedIn = await AuthService.signUp(
        name: name,
        email: email,
        password: password,
      );
      if (!mounted) return;
      if (signedIn) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRouter.home, (_) => false);
      } else {
        // Project has email confirmation enabled.
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirm your email'),
            content: Text(
                'We sent a confirmation link to $email. Confirm it, then sign in.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        if (mounted) Navigator.of(context).pop(); // back to login
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Could not sign up: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF98CBCC),
      body: Stack(
        children: [
          const Positioned(
            top: 90,
            left: 0,
            right: 0,
            child: Center(child: BackgroundTitle(text: 'Join us,')),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Image.asset('assets/images/logo.png', width: 96, height: 96),
                    const SizedBox(height: 32),
                    GlassCard(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create account',
                            style: TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              fontWeight: FontWeight.w600,
                              fontSize: 32,
                              color: Color(0xFF1A181B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Start your crystal collection',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                              color: Color(0xFF5E5E5E),
                            ),
                          ),
                          const SizedBox(height: 24),
                          GlassTextField(controller: _name, hint: 'Name'),
                          const SizedBox(height: 12),
                          GlassTextField(
                            controller: _email,
                            hint: 'Email',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          GlassTextField(
                            controller: _password,
                            hint: 'Password (min. 6 characters)',
                            obscure: true,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: GradientButton(
                              label: 'Create account',
                              loading: _loading,
                              onPressed: _signUp,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                'Already have an account? Sign in',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(0xFF29686A),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
