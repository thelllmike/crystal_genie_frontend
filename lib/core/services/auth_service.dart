import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around Supabase Auth.
class AuthService {
  static SupabaseClient get _client => Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;
  static bool get isLoggedIn => _client.auth.currentSession != null;

  static String get displayName {
    final metaName = currentUser?.userMetadata?['name'] as String?;
    if (metaName != null && metaName.trim().isNotEmpty) return metaName.trim();
    final email = currentUser?.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'there';
  }

  static String get email => currentUser?.email ?? '';

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  /// Returns true when a session was created right away; false when the
  /// project requires email confirmation first.
  static Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    return res.session != null;
  }

  static Future<void> signOut() => _client.auth.signOut();

  /// Deep link the OAuth providers redirect back to (registered in
  /// AndroidManifest.xml and Info.plist).
  static const _oauthCallback = 'com.crystalgenie.app://login-callback/';

  /// Opens the browser for Google sign-in; the session arrives via the
  /// deep link and fires onAuthStateChange.
  static Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: _oauthCallback,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  /// Sign in with Apple — required by the App Store when Google login
  /// is offered (guideline 4.8).
  static Future<void> signInWithApple() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: _oauthCallback,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  /// Permanently deletes the account (App Store guideline 5.1.1(v)).
  /// Uses the delete_user() Postgres function; all user rows cascade.
  static Future<void> deleteAccount() async {
    await _client.rpc('delete_user');
    await _client.auth.signOut();
  }

  static Future<void> updateDisplayName(String name) async {
    await _client.auth.updateUser(UserAttributes(data: {'name': name}));
  }

  static Future<void> changePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  static bool get notificationsEnabled =>
      (currentUser?.userMetadata?['notifications_enabled'] as bool?) ?? true;

  static Future<void> setNotificationsEnabled(bool enabled) async {
    await _client.auth
        .updateUser(UserAttributes(data: {'notifications_enabled': enabled}));
  }

  /// Initials for the avatar (e.g. "sachin harshitha" -> "SH").
  static String get initials {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase());
    final joined = parts.join();
    return joined.isEmpty ? '?' : joined;
  }
}
