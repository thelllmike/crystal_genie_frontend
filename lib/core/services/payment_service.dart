import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/api_config.dart';
import '../constants/stripe_config.dart';

/// Card payments via Stripe's native payment sheet.
///
/// The amount is never sent from the app — the backend computes it from the
/// signed-in user's cart, creates the PaymentIntent, and returns only its
/// client secret.
class PaymentService {
  static const _baseUrl = ApiConfig.baseUrl;

  /// Charges the current cart. Returns `true` on a completed payment and
  /// `false` if the user dismissed the sheet. Throws on any real failure.
  static Future<bool> payForCart() async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) {
      throw Exception('You must be signed in to pay');
    }

    // 1. Ask the backend to create a PaymentIntent for our cart.
    final resp = await http.post(
      Uri.parse('$_baseUrl/create-payment-intent'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode != 200) {
      throw Exception(_errorFrom(resp));
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    final clientSecret = data['clientSecret'] as String;

    // Use the publishable key the backend returned, so the app and backend
    // can never point at different Stripe accounts/modes.
    final publishableKey = data['publishableKey'] as String?;
    if (publishableKey != null &&
        publishableKey.isNotEmpty &&
        Stripe.publishableKey != publishableKey) {
      Stripe.publishableKey = publishableKey;
      await Stripe.instance.applySettings();
    }

    // 2. Build and show the payment sheet.
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: StripeConfig.merchantDisplayName,
        style: ThemeMode.light,
      ),
    );

    // 3. Present it. A dismissed sheet throws with FailureCode.Canceled.
    try {
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return false;
      rethrow;
    }
  }

  static String _errorFrom(http.Response resp) {
    try {
      final body = json.decode(resp.body) as Map<String, dynamic>;
      final detail = body['detail'];
      if (detail is String && detail.isNotEmpty) return detail;
    } catch (_) {
      // fall through to the generic message
    }
    return 'Could not start payment (${resp.statusCode})';
  }
}
