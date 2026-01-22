import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeService {
  static final StripeService instance = StripeService._();
  StripeService._();

  // IMPORTANT: The user will provide these later.
  String _publishableKey = '';
  // This should be your backend URL (e.g. Firebase Cloud Function)
  String _backendUrl = 'https://YOUR_BACKEND_URL/create-payment-intent';

  void init(String publishableKey) {
    _publishableKey = publishableKey;
    Stripe.publishableKey = _publishableKey;
  }

  Future<bool> makePayment({
    required double amount,
    required String currency,
    required BuildContext context,
  }) async {
    try {
      // 1. Create Payment Intent on backend
      final paymentIntentData = await _createPaymentIntent(
        (amount * 100).toInt().toString(), // Stripe expects amount in cents
        currency,
      );

      if (paymentIntentData == null) return false;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment Failed: ${e.error.localizedMessage}'),
          ),
        );
      }
      return false;
    } catch (e) {
      debugPrint('Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred')),
        );
      }
      return false;
    }
  }

  Future<Map<String, dynamic>?> _createPaymentIntent(
    String amount,
    String currency,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        body: {'amount': amount, 'currency': currency},
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
      return null;
    }
  }
}
