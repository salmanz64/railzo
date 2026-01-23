import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeService {
  static final StripeService instance = StripeService._();
  StripeService._();

  // IMPORTANT: For development/testing, you can use the Secret Key directly.
  // In production, ALWAYS use a backend server.
  String _publishableKey = '';
  String _secretKey = ''; // Optional: for direct API calls
  String _backendUrl = 'https://YOUR_BACKEND_URL/create-payment-intent';

  void init({
    required String publishableKey,
    String? secretKey,
    String? backendUrl,
  }) {
    _publishableKey = publishableKey;
    if (secretKey != null) _secretKey = secretKey;
    if (backendUrl != null) _backendUrl = backendUrl;
    Stripe.publishableKey = _publishableKey;
  }

  Future<bool> makePayment({
    required double amount,
    required String currency,
    required BuildContext context,
  }) async {
    try {
      // 1. Create Payment Intent
      Map<String, dynamic>? paymentIntentData;

      if (_secretKey.isNotEmpty && _secretKey != 'YOUR_SECRET_KEY') {
        // Direct call to Stripe API (Useful for testing/demo)
        paymentIntentData = await _createPaymentIntentDirectly(
          (amount * 100).toInt().toString(),
          currency,
        );
      } else {
        // Call your backend
        paymentIntentData = await _createPaymentIntent(
          (amount * 100).toInt().toString(),
          currency,
        );
      }

      if (paymentIntentData == null ||
          paymentIntentData['client_secret'] == null) {
        throw Exception('Failed to create payment intent');
      }

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          merchantDisplayName: 'Railzo',
          style: ThemeMode.light,
        ),
      );

      // 3. Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      return true;
    } on StripeException catch (e) {
      debugPrint('Stripe Error: ${e.error.localizedMessage}');
      if (context.mounted) {
        String message = e.error.localizedMessage ?? 'Payment Failed';
        if (e.error.code == FailureCode.Canceled) {
          message = 'Payment Cancelled';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
      return false;
    } catch (e) {
      debugPrint('Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
      return false;
    }
  }

  // Backend call version
  Future<Map<String, dynamic>?> _createPaymentIntent(
    String amount,
    String currency,
  ) async {
    try {
      if (_backendUrl.contains('YOUR_BACKEND_URL')) {
        debugPrint('Error: Backend URL not configured');
        return null;
      }
      final response = await http.post(
        Uri.parse(_backendUrl),
        body: {'amount': amount, 'currency': currency},
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error creating payment intent via backend: $e');
      return null;
    }
  }

  // Direct API call version (For testing)
  Future<Map<String, dynamic>?> _createPaymentIntentDirectly(
    String amount,
    String currency,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount,
          'currency': currency,
          'payment_method_types[]': 'card',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error creating payment intent directly: $e');
      return null;
    }
  }
}
