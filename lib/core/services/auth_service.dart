import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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

  static bool get _isIOS => !kIsWeb && Platform.isIOS;

  /// Opens a browser for Google sign-in; the session arrives via the deep
  /// link and fires onAuthStateChange. On iPhone it stays inside the app —
  /// App Review rejects logins that bounce out to Safari (guideline 4.0).
  static Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: _oauthCallback,
      authScreenLaunchMode: _isIOS
          ? LaunchMode.inAppBrowserView
          : LaunchMode.externalApplication,
    );
  }

  /// Sign in with Apple — required by the App Store when Google login
  /// is offered (guideline 4.8). Uses the native Apple sheet; needs the
  /// app's bundle id listed under Client IDs in Supabase → Auth → Apple.
  ///
  /// Returns quietly if the user closes the sheet.
  static Future<void> signInWithApple() async {
    // Supabase checks the token against the hashed nonce Apple signed into it.
    final rawNonce = _randomNonce();
    final AuthorizationCredentialAppleID credential;
    try {
      credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return;
      rethrow;
    }

    final idToken = credential.identityToken;
    if (idToken == null) throw Exception('Apple did not return an ID token');
    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );

    // Apple only shares the name on the very first sign-in.
    final name = [credential.givenName, credential.familyName]
        .whereType<String>()
        .join(' ')
        .trim();
    if (name.isNotEmpty && (currentUser?.userMetadata?['name'] == null)) {
      await updateDisplayName(name);
    }
  }

  static String _randomNonce([int length = 32]) {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
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

  // ---------- Saved shipping address (stored in user metadata) ----------

  static Map<String, dynamic> get _meta => currentUser?.userMetadata ?? {};

  static String get shipName => (_meta['ship_name'] as String?) ?? '';
  static String get shipPhone => (_meta['ship_phone'] as String?) ?? '';
  static String get shipAddress => (_meta['ship_address'] as String?) ?? '';
  static String get shipCity => (_meta['ship_city'] as String?) ?? '';
  static String get shipPostal => (_meta['ship_postal'] as String?) ?? '';

  static bool get hasSavedAddress => shipAddress.isNotEmpty;

  /// Persists the shipping address to the user's metadata so checkout can
  /// prefill it next time. Merges with existing metadata (name, etc.).
  static Future<void> saveShippingAddress({
    required String name,
    required String phone,
    required String address,
    required String city,
    required String postal,
  }) async {
    await _client.auth.updateUser(UserAttributes(data: {
      'ship_name': name,
      'ship_phone': phone,
      'ship_address': address,
      'ship_city': city,
      'ship_postal': postal,
    }));
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
