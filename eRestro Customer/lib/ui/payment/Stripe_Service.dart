import 'dart:convert';
import 'dart:math';

import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/ui/cart/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeTransactionResponse {
  final String? message, status;
  bool? success;

  StripeTransactionResponse({this.message, this.success, this.status});
}

class StripeService {
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
  static String? secret;

  static Map<String, String> headers = {'Authorization': 'Bearer ${StripeService.secret}', 'Content-Type': 'application/x-www-form-urlencoded'};

  static init(String? stripeId, String? stripeMode) async {
    Stripe.publishableKey = stripeId ?? '';
    Stripe.merchantIdentifier = "App Identifier";
    await Stripe.instance.applySettings();
  }

  static Future<StripeTransactionResponse> payWithPaymentSheet({String? amount, String? currency, String? from, BuildContext? context}) async {
    try {
      //create Payment intent
      var paymentIntent = await (StripeService.createPaymentIntent(amount, currency, from, context));

      //setting up Payment Sheet
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent!['client_secret'],
              applePay: true,
              googlePay: true,
              merchantCountryCode: 'IN',
              style: ThemeMode.light,
              merchantDisplayName: 'Test'));

      //open payment sheet
      await Stripe.instance.presentPaymentSheet();

      //store paymentID of customer
      stripePayId = paymentIntent['id'];

      //confirm payment
      var response = await http.post(Uri.parse('${StripeService.paymentApiUrl}/$stripePayId'), headers: headers);

      var getdata = json.decode(response.body);
      var statusOfTransaction = getdata['status'];

      if (statusOfTransaction == 'succeeded') {
        return StripeTransactionResponse(message: 'Transaction successful', success: true, status: statusOfTransaction);
      } else if (statusOfTransaction == 'pending' || statusOfTransaction == 'captured') {
        return StripeTransactionResponse(message: 'Transaction pending', success: true, status: statusOfTransaction);
      } else {
        return StripeTransactionResponse(message: 'Transaction failed', success: false, status: statusOfTransaction);
      }
    } on PlatformException catch (err) {
      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
      return StripeTransactionResponse(message: 'Transaction failed: ${err.toString()}', success: false, status: 'fail');
    }
  }

  static getPlatformExceptionErrorResult(err) {
    String message = 'Something went wrong';
    if (err.code == 'cancelled') {
      message = 'Transaction cancelled';
    }

    return StripeTransactionResponse(message: message, success: false, status: 'cancelled');
  }

  static Future<Map<String, dynamic>?> createPaymentIntent(String? amount, String? currency, String? from, BuildContext? context) async {
    //SettingProvider settingsProvider = Provider.of<SettingProvider>(context!, listen: false);

    //pre-define style to add transaction using webhook
    String orderId =
        'wallet-refill-user-${context!.read<AuthCubit>().getId()}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}';

    try {
      Map<String, dynamic> parameter = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
        'description': from,
      };
      if (from == 'wallet') parameter['metadata[order_id]'] = orderId;

      var response = await http.post(Uri.parse(StripeService.paymentApiUrl), body: parameter, headers: StripeService.headers);

      return jsonDecode(response.body.toString());
    } catch (err) {
      print(err.toString());
    }
    return null;
  }
}
