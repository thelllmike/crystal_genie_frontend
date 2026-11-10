import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app_router.dart';
import '../../core/services/auth_service.dart';
import '../widgets/cg.dart';

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
    CG.snack(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final showApple = !kIsWeb && Platform.isIOS;
    return CGPage(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight - 40),
              child: IntrinsicHeight(
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _BrandMark(),
                      const SizedBox(height: 44),
                      const CGHeading(
                        eyebrow: 'Welcome back',
                        title: 'Sign in to your collection.',
                      ),
                      const SizedBox(height: 10),
                      Text('Your crystals are waiting for you.', style: CG.sub()),
                      const SizedBox(height: 30),
                      CGField(
                        label: 'Email',
                        controller: _email,
                        hint: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        action: TextInputAction.next,
                        autofill: const [AutofillHints.email],
                      ),
                      const SizedBox(height: 16),
                      CGField(
                        label: 'Password',
                        controller: _password,
                        hint: 'Your password',
                        obscure: true,
                        action: TextInputAction.done,
                        autofill: const [AutofillHints.password],
                      ),
                      const SizedBox(height: 24),
                      CGButton(label: 'Sign in', loading: _loading, onPressed: _signIn),
                      const SizedBox(height: 22),
                      const CGDivider('or'),
                      const SizedBox(height: 22),
                      CGButton.ghost(
                        label: 'Continue with Google',
                        onPressed: () => _oauth(AuthService.signInWithGoogle, 'Google'),
                      ),
                      if (showApple) ...[
                        const SizedBox(height: 12),
                        CGButton.ghost(
                          label: 'Continue with Apple',
                          icon: Icons.apple,
                          onPressed: () => _oauth(AuthService.signInWithApple, 'Apple'),
                        ),
                      ],
                      const Spacer(),
                      const SizedBox(height: 24),
                      Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text('New here?', style: CG.sub()),
                            CGLink(
                              'Create an account',
                              size: 15,
                              onTap: () => Navigator.of(context).pushNamed(AppRouter.signup),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Gem(color: Color(0xFFA98BFF), width: 22),
          const SizedBox(width: 10),
          Text('Crystal Genie', style: CG.display(20)),
        ],
      );
}
