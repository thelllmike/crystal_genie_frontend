import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Asks the backend to email the buyer their order confirmation.
///
/// The message is sent from the shop's admin mailbox to the address on the
/// signed-in account; the app only supplies the order id.
class OrderEmailService {
  // Same host as [ApiService] and [PaymentService]: the FastAPI backend.
  static const _baseUrl = 'http://localhost:8000';

  /// Fire-and-forget: a failed email must never look like a failed order, so
  /// this swallows errors and reports whether the send went through.
  static Future<bool> sendConfirmation(int orderId) async {
    try {
      final token = Supabase.instance.client.auth.currentSession?.accessToken;
      if (token == null) return false;

      final resp = await http.post(
        Uri.parse('$_baseUrl/orders/$orderId/confirmation-email'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (resp.statusCode != 200) return false;
      final body = json.decode(resp.body) as Map<String, dynamic>;
      return body['sent'] == true;
    } catch (_) {
      return false;
    }
  }
}
