import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app_router.dart';
import '../../core/services/auth_service.dart';
import '../widgets/cg.dart';

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
          builder: (ctx) => CGDialog(
            icon: HugeIcons.strokeRoundedMail01,
            title: 'Confirm your email',
            body: Text(
              'We sent a confirmation link to $email. Confirm it, then sign in.',
              style: CG.sub(14.5).copyWith(height: 1.55),
            ),
            actions: [
              CGButton(label: 'OK', onPressed: () => Navigator.of(ctx).pop()),
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
      glow: CG.mint,
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
                      Row(
                        children: [
                          const Gem(color: Color(0xFFA98BFF), width: 22),
                          const SizedBox(width: 10),
                          Expanded(child: Text('Crystal Genie', style: CG.display(20))),
                        ],
                      ),
                      const SizedBox(height: 44),
                      const CGHeading(
                        eyebrow: 'Join us',
                        title: 'Start your crystal collection.',
                      ),
                      const SizedBox(height: 10),
                      Text('Free to try. Scan, save and learn.', style: CG.sub()),
                      const SizedBox(height: 30),
                      CGField(
                        label: 'Name',
                        controller: _name,
                        hint: 'Your name',
                        action: TextInputAction.next,
                        autofill: const [AutofillHints.name],
                      ),
                      const SizedBox(height: 16),
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
                        hint: 'At least 6 characters',
                        obscure: true,
                        action: TextInputAction.done,
                        autofill: const [AutofillHints.newPassword],
                      ),
                      const SizedBox(height: 24),
                      CGButton(label: 'Create account', loading: _loading, onPressed: _signUp),
                      const SizedBox(height: 22),
                      const CGDivider('or'),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: CGButton.ghost(
                              label: 'Google',
                              onPressed: () => _oauth(AuthService.signInWithGoogle, 'Google'),
                            ),
                          ),
                          if (showApple) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: CGButton.ghost(
                                label: 'Apple',
                                icon: Icons.apple,
                                onPressed: () => _oauth(AuthService.signInWithApple, 'Apple'),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Spacer(),
                      const SizedBox(height: 24),
                      Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text('Already have an account?', style: CG.sub()),
                            CGLink('Sign in', size: 15, onTap: () => Navigator.of(context).pop()),
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
