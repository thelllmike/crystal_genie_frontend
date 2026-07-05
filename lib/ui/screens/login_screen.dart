import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app_router.dart';
import '../../core/services/auth_service.dart';
import '../widgets/glass.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    // Navigates after any successful sign-in, including the OAuth
    // redirect that comes back through the deep link.
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((state) {
      if (state.event == AuthChangeEvent.signedIn && mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRouter.home, (_) => false);
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill in your email and password');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.signIn(email: email, password: password);
      // Navigation happens in the onAuthStateChange listener.
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Could not sign in: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _oauth(Future<void> Function() provider, String label) async {
    try {
      await provider();
    } catch (e) {
      _showError('$label sign-in failed: $e');
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
            child: Center(child: BackgroundTitle(text: 'Welcome back,')),
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
                            'Sign in',
                            style: TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              fontWeight: FontWeight.w600,
                              fontSize: 32,
                              color: Color(0xFF1A181B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Your crystals are waiting for you',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                              color: Color(0xFF5E5E5E),
                            ),
                          ),
                          const SizedBox(height: 24),
                          GlassTextField(
                            controller: _email,
                            hint: 'Email',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          GlassTextField(
                            controller: _password,
                            hint: 'Password',
                            obscure: true,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: GradientButton(
                              label: 'Sign in',
                              loading: _loading,
                              onPressed: _signIn,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: const [
                              Expanded(child: Divider(color: Color(0x80FBF5F3))),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w300,
                                    fontSize: 12,
                                    color: Color(0xFF5E5E5E),
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Color(0x80FBF5F3))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _SocialButton(
                            label: 'Continue with Google',
                            icon: Icons.g_mobiledata_rounded,
                            onPressed: () => _oauth(
                                AuthService.signInWithGoogle, 'Google'),
                          ),
                          if (!kIsWeb && Platform.isIOS) ...[
                            const SizedBox(height: 8),
                            _SocialButton(
                              label: 'Continue with Apple',
                              icon: Icons.apple,
                              onPressed: () =>
                                  _oauth(AuthService.signInWithApple, 'Apple'),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(AppRouter.signup),
                              child: const Text(
                                'New here? Create an account',
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

/// Outlined glass-style button for third-party sign-in providers.
class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22, color: const Color(0xFF1A181B)),
        label: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF1A181B),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0x80FBF5F3),
          side: const BorderSide(color: Color(0x80FBF5F3), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
