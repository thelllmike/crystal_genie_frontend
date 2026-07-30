import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/stripe_config.dart';

/// A user's trial/subscription state, as reported by the backend.
class SubscriptionStatus {
  /// trialing | active | past_due | canceled
  final String status;
  final bool hasAccess;
  final int trialDaysLeft;
  final DateTime? trialEndsAt;
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final String priceLabel;

  const SubscriptionStatus({
    required this.status,
    required this.hasAccess,
    required this.trialDaysLeft,
    required this.trialEndsAt,
    required this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
    required this.priceLabel,
  });

  bool get isTrialing => status == 'trialing';
  bool get isSubscribed => status == 'active' || status == 'past_due';

  /// True while the trial is still running — used to nudge without blocking.
  bool get isTrialActive => isTrialing && hasAccess;

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    DateTime? parse(String? value) =>
        value == null ? null : DateTime.tryParse(value)?.toLocal();
    return SubscriptionStatus(
      status: json['status'] as String? ?? 'trialing',
      hasAccess: json['hasAccess'] as bool? ?? false,
      trialDaysLeft: (json['trialDaysLeft'] as num?)?.toInt() ?? 0,
      trialEndsAt: parse(json['trialEndsAt'] as String?),
      currentPeriodEnd: parse(json['currentPeriodEnd'] as String?),
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool? ?? false,
      priceLabel: json['priceLabel'] as String? ?? '\$3.69/month',
    );
  }
}

/// Free trial + $3.69/month premium, used to gate crystal scanning.
///
/// Paid status is decided by Stripe and written to the database by the
/// backend's webhook — the app only ever reads it.
class SubscriptionService {
  // Same host as [ApiService] and [PaymentService]: the FastAPI backend.
  static const _baseUrl = 'http://localhost:8000';

  /// Last known status. Kept so the camera tab can gate without a round trip
  /// on every shutter press.
  static SubscriptionStatus? current;

  /// Lets widgets rebuild when the status changes (paywall, profile).
  static final ValueNotifier<SubscriptionStatus?> notifier =
      ValueNotifier<SubscriptionStatus?>(null);

  static String? get _token =>
      Supabase.instance.client.auth.currentSession?.accessToken;

  static void _set(SubscriptionStatus status) {
    current = status;
    notifier.value = status;
  }

  /// Clears cached state — call on sign-out so the next user doesn't inherit
  /// the previous one's access.
  static void clear() {
    current = null;
    notifier.value = null;
  }

  /// Re-reads the status from the backend. Returns null if it can't be
  /// reached, leaving any previously known status in place.
  static Future<SubscriptionStatus?> refresh() async {
    final token = _token;
    if (token == null) return null;
    try {
      final resp = await http.get(
        Uri.parse('$_baseUrl/subscription'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (resp.statusCode != 200) return null;
      final status = SubscriptionStatus.fromJson(
        json.decode(resp.body) as Map<String, dynamic>,
      );
      _set(status);
      return status;
    } catch (_) {
      return null;
    }
  }

  /// Whether the user may scan right now.
  ///
  /// If the backend is unreachable we fall back to the last known status, and
  /// to allowing the scan when nothing is known — a network blip should never
  /// lock a paying customer out of the feature they bought.
  static Future<bool> hasAccess() async {
    final status = await refresh() ?? current;
    return status?.hasAccess ?? true;
  }

  /// Starts the subscription and confirms the first payment in Stripe's
  /// payment sheet. Returns true once access is granted.
  ///
  /// Throws with a readable message on failure; returns false if the user
  /// dismissed the sheet.
  static Future<bool> subscribe() async {
    final token = _token;
    if (token == null) throw Exception('You must be signed in to subscribe');

    final resp = await http.post(
      Uri.parse('$_baseUrl/subscription/subscribe'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode != 200) throw Exception(_errorFrom(resp));
    final data = json.decode(resp.body) as Map<String, dynamic>;

    // Keep the app on the same Stripe account/mode as the backend.
    final publishableKey = data['publishableKey'] as String?;
    if (publishableKey != null &&
        publishableKey.isNotEmpty &&
        Stripe.publishableKey != publishableKey) {
      Stripe.publishableKey = publishableKey;
      await Stripe.instance.applySettings();
    }

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: data['clientSecret'] as String,
        merchantDisplayName: StripeConfig.merchantDisplayName,
        style: ThemeMode.light,
      ),
    );

    try {
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return false;
      rethrow;
    }

    // The payment succeeded, but access is only granted once Stripe's webhook
    // reaches our backend. Poll briefly rather than showing a stale paywall.
    for (var attempt = 0; attempt < 6; attempt++) {
      final status = await refresh();
      if (status != null && status.isSubscribed) return true;
      await Future<void>.delayed(const Duration(milliseconds: 1200));
    }
    return current?.hasAccess ?? false;
  }

  /// Stops the subscription renewing; access lasts until the paid period ends.
  static Future<void> cancel() async {
    final token = _token;
    if (token == null) throw Exception('You must be signed in');
    final resp = await http.post(
      Uri.parse('$_baseUrl/subscription/cancel'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode != 200) throw Exception(_errorFrom(resp));
    await refresh();
  }

  static String _errorFrom(http.Response resp) {
    try {
      final body = json.decode(resp.body) as Map<String, dynamic>;
      final detail = body['detail'];
      if (detail is String && detail.isNotEmpty) return detail;
    } catch (_) {
      // fall through to the generic message
    }
    return 'Something went wrong (${resp.statusCode})';
  }
}
