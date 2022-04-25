import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/features/address/addressRepository.dart';
import 'package:erestro/features/address/cubit/addressCubit.dart';
import 'package:erestro/features/address/cubit/updateAddressCubit.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/cart/cartModel.dart';
import 'package:erestro/features/cart/cubits/getCartCubit.dart';
import 'package:erestro/features/home/search/cubit/filterCubit.dart';
import 'package:erestro/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:erestro/ui/payment/Stripe_Service.dart';
import 'package:erestro/ui/payment/payment_radio.dart';
import 'package:erestro/ui/payment/paypal_webview_screen.dart';
import 'package:erestro/ui/cart/cart_screen.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/ui/order/thank_you_for_order.dart';
import 'package:erestro/ui/widgets/addressSimmer.dart';
import 'package:erestro/ui/widgets/cartSimmer.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';
import 'package:erestro/utils/internetConnectivity.dart';
import 'package:erestro/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:paytm/paytm.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final CartModel? cartModel;
  final String? addNote;
  const PaymentScreen({Key? key, this.cartModel, this.addNote}) : super(key: key);

  @override
  PaymentScreenState createState() => PaymentScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<FilterCubit>(
              create: (_) => FilterCubit(),
              child: PaymentScreen(cartModel: arguments['cartModel'] as CartModel, addNote: arguments['addNote']),
            ));
  }
}

bool codAllowed = true;
String? bankName, bankNo, acName, acNo, exDetails;

class PaymentScreenState extends State<PaymentScreen> {
  double? width, height;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  int? addressIndex;
  bool _isLoading = true;
  String? startingDate;

  late bool cod = false,
      paypal = false,
      razorpay = false,
      paumoney = false,
      paystack = false,
      flutterwave = false,
      stripe = false,
      paytm = true,
      gpay = false;
  List<RadioModel> paymentModel = [];

  List<String?> paymentMethodList = [];
  List<String> paymentIconList = [
    Platform.isIOS ? 'applepay' : 'gpay',
    'cash_delivery',
    'paypal',
    'payu',
    'rozerpay',
    'paystack',
    'flutterwave',
    'stripe',
    'paytm',
  ];

  Razorpay? _razorpay;
  final payStackPlugin = PaystackPlugin();
  bool _placeOrder = true;
  final plugin = PaystackPlugin();
  String addressId = "";

  @override
  void initState() {
    super.initState();
    //print("addNote:" + widget.addNote!);
    context.read<SystemConfigCubit>().getSystemConfig(context.read<AuthCubit>().getId());
    getDateTime();
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });
    context.read<AddressCubit>().fetchAddress(context.read<AuthCubit>().getId());
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    Future.delayed(Duration.zero, () {
      paymentMethodList = [
        Platform.isIOS ? StringsRes.applePayLbl : StringsRes.applePayLbl,
        StringsRes.caseOnDeliveryLbl,
        StringsRes.payPalLbl,
        StringsRes.payumoneyLbl,
        StringsRes.razorpayLbl,
        StringsRes.payStackLbl,
        StringsRes.flutterWaveLbl,
        StringsRes.stripeLbl,
        StringsRes.paytmLbl,
      ];
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    //print("payment success" + response.toString());
    placeOrder(response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    //print("payment error" + response.toString());
    var getdata = json.decode(response.message!);
    String errorMsg = getdata["error"]["description"];
    UiUtils.setSnackBar(errorMsg, errorMsg, context, false);

    if (mounted) {
      _placeOrder = true;
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  Future<void> getDateTime() async {
    try {
      var parameter = {typeKey: paymentMethodKey, userIdKey: context.read<AuthCubit>().getId()};
      Response response = await post(Uri.parse(getSettingsUrl), body: parameter, headers: ApiUtils.getHeaders()).timeout(const Duration(seconds: 50));

      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        if (!error) {
          var data = getdata["data"];
          codAllowed = data["is_cod_allowed"] == 1 ? true : false;

          var payment = data["payment_method"];

          cod = codAllowed
              ? payment["cod_method"] == "1"
                  ? true
                  : false
              : false;
          paypal = payment["paypal_payment_method"] == "1" ? true : false;
          paumoney = payment["payumoney_payment_method"] == "1" ? true : false;
          flutterwave = payment["flutterwave_payment_method"] == "1" ? true : false;
          razorpay = payment["razorpay_payment_method"] == "1" ? true : false;
          paystack = payment["paystack_payment_method"] == "1" ? true : false;
          stripe = payment["stripe_payment_method"] == "1" ? true : false;
          paytm = payment["paytm_payment_method"] == "1" ? true : false;

          if (razorpay) razorpayId = payment["razorpay_key_id"];
          if (paystack) {
            paystackId = payment["paystack_key_id"];

            await plugin.initialize(publicKey: paystackId!);
          }
          if (stripe) {
            stripeId = payment['stripe_publishable_key'];
            stripeSecret = payment['stripe_secret_key'];
            stripeCurCode = payment['stripe_currency_code'];
            stripeMode = payment['stripe_mode'] ?? 'test';
            StripeService.secret = stripeSecret;
            StripeService.init(stripeId, stripeMode);
          }
          if (paytm) {
            paytmMerId = payment['paytm_merchant_id'];
            paytmMerKey = payment['paytm_merchant_key'];
            payTesting = payment['paytm_payment_mode'] == 'sandbox' ? true : false;
          }

          for (int i = 0; i < paymentMethodList.length; i++) {
            paymentModel.add(RadioModel(isSelected: i == selectedMethod ? true : false, name: paymentMethodList[i], img: paymentIconList[i]));
          }
        } else {}
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } on TimeoutException catch (_) {}
  }

  doPayment() {
    if (paymentMethod == StringsRes.payPalLbl) {
      placeOrder('');
    } else if (paymentMethod == StringsRes.razorpayLbl) {
      razorpayPayment();
    } else if (paymentMethod == StringsRes.payStackLbl) {
      payStackPayment(context);
    } else if (paymentMethod == StringsRes.flutterWaveLbl) {
      flutterWavePayment();
    } else if (paymentMethod == StringsRes.stripeLbl) {
      stripePayment();
    } else if (paymentMethod == StringsRes.paytmLbl) {
      paytmPayment();
    } else {
      placeOrder('');
    }
  }

  void paytmPayment() async {
    String? paymentResponse;

    String orderId = DateTime.now().millisecondsSinceEpoch.toString();

    String callBackUrl = (payTesting ? 'https://securegw-stage.paytm.in' : 'https://securegw.paytm.in') + '/theia/paytmCallback?ORDER_ID=' + orderId;
    //print(callBackUrl);
    var parameter = {amountKey: finalTotal.toString(), userIdKey: context.read<AuthCubit>().getId(), orderIdKey: orderId};
    //print(parameter);

    try {
      final response = await post(
        Uri.parse(generatePaytmTxnTokenUrl),
        body: parameter,
        headers: ApiUtils.getHeaders(),
      );

      var getdata = json.decode(response.body);

      bool error = getdata["error"];

      if (!error) {
        String txnToken = getdata["txn_token"];
        //print("isvar--${txnToken}");

        setState(() {
          paymentResponse = txnToken;
        });
        // orderId, mId, txnToken, txnAmount, callback

        var paytmResponse = Paytm.payWithPaytm(
            callBackUrl: callBackUrl, mId: paytmMerId!, orderId: orderId, txnToken: txnToken, txnAmount: finalTotal.toString(), staging: payTesting);
        paytmResponse.then((value) {
          _placeOrder = true;
          setState(() {});
          if (value['error']) {
            paymentResponse = value['errorMessage'];

            if (value['response'] != "") {
              addTransaction(value['response']['TXNID'], orderId, value['response']['STATUS'] ?? '', paymentResponse, false);
            }
          } else {
            if (value['response'] != "") {
              paymentResponse = value['response']['STATUS'];
              if (paymentResponse == "TXN_SUCCESS") {
                placeOrder(value['response']['TXNID']);
              } else {
                addTransaction(value['response']['TXNID'], orderId, value['response']['STATUS'], value['errorMessage'] ?? '', false);
              }
            }
          }
          UiUtils.setSnackBar(StringsRes.payment, paymentResponse!, context, false);
        });
      } else {
        _placeOrder = true;
        UiUtils.setSnackBar(StringsRes.payment, getdata["message"], context, false);
      }
    } catch (e) {
      print(e);
    }
  }

  razorpayPayment() async {
    String? contact = context.read<SystemConfigCubit>().getMobile();
    String? email = context.read<SystemConfigCubit>().getEmail();
    String? name = context.read<SystemConfigCubit>().getName();

    String? amt = ((finalTotal) * 100).toStringAsFixed(2);
    //print(contact + "" + email + "" + amt + "" + razorpayId.toString() + "" + context.read<SystemConfigCubit>().getName().toString());
    if (contact != '' && email != '') {
      var options = {
        key: razorpayId,
        amountKey: amt,
        nameKey: name,
        'prefill': {contactKey: contact, emailKey: email},
      };

      try {
        _razorpay!.open(options);
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      if (email == '') {
        UiUtils.setSnackBar(StringsRes.email, 'emailWarning', context, false);
      } else if (contact == '') {
        UiUtils.setSnackBar(StringsRes.phoneNumber, 'phoneWarning', context, false);
      }
    }
  }

  payStackPayment(BuildContext context) async {
    await payStackPlugin.initialize(publicKey: paystackId!);
    String? email = context.read<SystemConfigCubit>().getEmail();

    Charge charge = Charge()
      ..amount = finalTotal.toInt()
      ..reference = _getReference()
      ..email = email;

    try {
      CheckoutResponse response = await payStackPlugin.checkout(
        context,
        method: CheckoutMethod.card,
        charge: charge,
      );
      if (response.status) {
        placeOrder(response.reference);
      } else {
        UiUtils.setSnackBar(StringsRes.payment, response.message, context, false);
        if (mounted) {
          setState(() {
            _placeOrder = true;
          });
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> placeOrder(String? tranId) async {
    String? mob = context.read<SystemConfigCubit>().getMobile();
    String? varientId, quantity;
    final cartModel = context.read<GetCartCubit>().getCartModel();
    varientId = cartModel.variantId!.join(",");
    for (int i = 0; i < cartModel.data!.length; i++) {
      quantity = quantity != null ? quantity + "," + cartModel.data![i].qty! : cartModel.data![i].qty!;
    }

    String? payVia;
    if (paymentMethod == StringsRes.caseOnDeliveryLbl) {
      payVia = "COD";
    } else if (paymentMethod == StringsRes.payPalLbl) {
      payVia = "PayPal";
    } else if (paymentMethod == StringsRes.payumoneyLbl) {
      payVia = "PayUMoney";
    } else if (paymentMethod == StringsRes.razorpayLbl) {
      payVia = "RazorPay";
    } else if (paymentMethod == StringsRes.payStackLbl) {
      payVia = "Paystack";
    } else if (paymentMethod == StringsRes.flutterWaveLbl) {
      payVia = "Flutterwave";
    } else if (paymentMethod == StringsRes.stripeLbl) {
      payVia = "Stripe";
    } else if (paymentMethod == StringsRes.paytmLbl) {
      payVia = "Paytm";
    } else if (paymentMethod == "Wallet") {
      payVia = "Wallet";
    }
    try {
      var parameter = {
        userIdKey: context.read<AuthCubit>().getId(),
        mobileKey: context.read<SystemConfigCubit>().getMobile(),
        productVariantIdKey: varientId,
        quantityKey: quantity,
        totalKey: subTotal.toString(),
        finalTotalKey: finalTotal.toString(),
        deliveryChargeKey: deliveryCharge.toString(),
        taxAmountKey: taxAmount.toString(),
        promoCodeKey: promoCode ?? "",
        taxPercentageKey: taxPercentage.toString(),
        latitudeKey: latitude.toString(),
        longitudeKey: longitude.toString(),
        paymentMethodKey: payVia,
        addressIdKey: selAddress,
        isWalletUsedKey: isUseWallet! ? "1" : "0",
        walletBalanceUsedKey: walletBalanceUsed.toString(),
        orderNoteKey: widget.addNote,
        deliveryTipKey: deliveryTip.toString(),
      };

      //print("body:" + parameter.toString());

      if (isPromoValid!) {
        parameter[promoCodeKey] = promoCode;
      }

      if (paymentMethod == StringsRes.payPalLbl) {
        parameter["active_status"] = waitingKey;
      } else if (paymentMethod == StringsRes.stripeLbl) {
        parameter["active_status"] = waitingKey;
      }

      Response response = await post(Uri.parse(placeOrderUrl), body: parameter, headers: ApiUtils.getHeaders()).timeout(const Duration(seconds: 50));

      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          String orderId = getdata["order_id"].toString();
          print("orderId:" + orderId);
          if (paymentMethod == StringsRes.razorpayLbl) {
            addTransaction(tranId, orderId, "Success", msg, true);
          } else if (paymentMethod == StringsRes.payPalLbl) {
            paypalPayment(orderId);
          } else if (paymentMethod == StringsRes.stripeLbl) {
            addTransaction(stripePayId, orderId, tranId == "succeeded" ? placedKey : waitingKey, msg, true);
          } else if (paymentMethod == StringsRes.payStackLbl) {
            addTransaction(tranId, orderId, "Success", msg, true);
          } else if (paymentMethod == StringsRes.paytmLbl) {
            addTransaction(tranId, orderId, "Success", msg, true);
          } else {
            clearAll();

            Navigator.pushAndRemoveUntil(
                context, CupertinoPageRoute(builder: (BuildContext context) => const ThankYouForOrderScreen()), ModalRoute.withName('/home'));
          }
        } else {
          UiUtils.setSnackBar(StringsRes.payment, msg!, context, false);
        }
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        _placeOrder = true;
      }
    }
  }

  Future<void> paypalPayment(String orderId) async {
    try {
      var parameter = {userIdKey: context.read<AuthCubit>().getId(), orderIdKey: orderId, amountKey: finalTotal.toString()};
      Response response =
          await post(Uri.parse(getPaypalLinkUrl), body: parameter, headers: ApiUtils.getHeaders()).timeout(const Duration(seconds: 50));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        String? data = getdata["data"];
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (BuildContext context) => PaypalWebView(
                      url: data,
                      from: "order",
                      orderId: orderId,
                      addNote: widget.addNote,
                    )));
      } else {
        UiUtils.setSnackBar(StringsRes.payment, msg!, context, false);
      }
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(StringsRes.payment, 'somethingMSg', context, false);
    }
  }

  clearAll() {
    finalTotal = 0;
    subTotal = 0;
    taxPercentage = 0;
    deliveryCharge = 0;
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {});

    promoAmt = 0;
    remWalBal = 0;
    walletBalanceUsed = 0;
    paymentMethod = '';
    promoCode = '';
    isPromoValid = false;
    isUseWallet = false;
    isPayLayShow = true;
    selectedMethod = null;
  }

  stripePayment() async {
    var response = await StripeService.payWithPaymentSheet(
        amount: (finalTotal.toInt() * 100).toString(), currency: stripeCurCode, from: "order", context: context);

    if (response.message == "Transaction successful") {
      placeOrder(response.status);
    } else if (response.status == 'pending' || response.status == "captured") {
      placeOrder(response.status);
    } else {
      if (mounted) {
        setState(() {
          _placeOrder = true;
        });
      }
    }
    UiUtils.setSnackBar(StringsRes.payment, response.message!, context, false);
  }

  Future<void> addTransaction(String? tranId, String orderID, String? status, String? msg, bool redirect) async {
    try {
      var parameter = {
        userIdKey: context.read<AuthCubit>().getMobile(),
        orderIdKey: orderID,
        typeKey: paymentMethod,
        txnIdKey: tranId,
        amountKey: finalTotal.toString(),
        statusKey: status,
        messageKey: msg
      };
      Response response =
          await post(Uri.parse(addTransactionUrl), body: parameter, headers: ApiUtils.getHeaders()).timeout(const Duration(seconds: 50));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String? msg1 = getdata["message"];
      if (!error) {
        if (redirect) {
          Navigator.pushAndRemoveUntil(
              context, CupertinoPageRoute(builder: (BuildContext context) => const ThankYouForOrderScreen()), ModalRoute.withName('/home'));
        }
      } else {
        UiUtils.setSnackBar(StringsRes.payment, msg!, context, false);
      }
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(StringsRes.payment, 'somethingMSg', context, false);
    }
  }

  Future<void> flutterWavePayment() async {
    try {
      var parameter = {
        amountKey: finalTotal.toString(),
        userIdKey: context.read<AuthCubit>().getId(),
      };
      //print(parameter.toString());
      Response response =
          await post(Uri.parse(flutterwaveWebviewUrl), body: parameter, headers: ApiUtils.getHeaders()).timeout(const Duration(seconds: 50));
      //print("payment" + response.body.toString());
      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["link"];
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (BuildContext context) => PaypalWebView(
                        url: data,
                        from: "order",
                        addNote: widget.addNote,
                      )));
        } else {
          UiUtils.setSnackBar(StringsRes.payment, msg!, context, false);
        }
      }
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(StringsRes.payment, 'somethingMSg', context, false);
    }
  }

  Widget deliveryLocation() {
    return Padding(
      padding: EdgeInsets.only(bottom: height! / 40.0),
      child: BlocProvider<UpdateAddressCubit>(
        create: (_) => UpdateAddressCubit(AddressRepository()),
        child: Builder(builder: (context) {
          return BlocConsumer<AddressCubit, AddressState>(
              bloc: context.read<AddressCubit>(),
              listener: (context, state) {},
              builder: (context, state) {
                if (state is AddressProgress || state is AddressInitial) {
                  return AddressSimmer(width: width!, height: height!);
                }
                if (state is AddressFailure) {
                  return Center(
                      child: Text(
                    state.errorCode.toString(),
                    textAlign: TextAlign.center,
                  ));
                }
                final addressList = (state as AddressSuccess).addressList;
                return ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: addressList.length,
                    itemBuilder: (BuildContext context, i) {
                      if (addressList[i].isDefault == "1") {
                        addressIndex = i;
                        addressId = addressList[i].id!;
                      }
                      return addressList[i].isDefault == "0"
                          ? Container()
                          : Container(
                              margin: const EdgeInsets.only(top: 5),
                              padding: EdgeInsets.only(bottom: height! / 99.0, left: width! / 40.0, right: width! / 40.0),
                              child: Column(children: [
                                Row(children: [
                                  addressList[i].type == StringsRes.home
                                      ? SvgPicture.asset(
                                          DesignConfig.setSvgPath("home_address"),
                                        )
                                      : addressList[i].type == StringsRes.office
                                          ? SvgPicture.asset(DesignConfig.setSvgPath("work_address"))
                                          : SvgPicture.asset(DesignConfig.setSvgPath("other_address")),
                                  SizedBox(width: height! / 99.0),
                                  Text(
                                    addressList[i].type == StringsRes.home
                                        ? StringsRes.home
                                        : addressList[i].type == StringsRes.office
                                            ? StringsRes.office
                                            : StringsRes.other,
                                    style: const TextStyle(fontSize: 14, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500),
                                  ),
                                ]),
                                SizedBox(width: height! / 99.0),
                                Row(
                                  children: [
                                    SizedBox(width: width! / 11.0),
                                    Expanded(
                                      child: Text(
                                        addressList[i].address! +
                                            "," +
                                            addressList[i].area! +
                                            "," +
                                            addressList[i].city.toString() +
                                            "," +
                                            addressList[i].state! +
                                            "," +
                                            addressList[i].pincode!,
                                        style: const TextStyle(fontSize: 14, color: ColorsRes.backgroundDark),
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                )
                              ]),
                            );
                    });
              });
        }),
      ),
    );
  }

  @override
  void dispose() {
    if (_razorpay != null) _razorpay!.clear();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
        ),
        child: _connectionStatus == 'ConnectivityResult.none'
            ? const NoInternetScreen()
            : Scaffold(
                backgroundColor: ColorsRes.white,
                appBar: AppBar(
                  leading: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                          padding: EdgeInsets.only(left: width! / 20.0),
                          child: SvgPicture.asset(DesignConfig.setSvgPath("back_icon"), width: 32, height: 32))),
                  backgroundColor: ColorsRes.white,
                  shadowColor: ColorsRes.white,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(StringsRes.payment,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                ),
                body: BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                  return (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
                      ? Container()
                      : BlocConsumer<GetCartCubit, GetCartState>(
                          bloc: context.read<GetCartCubit>(),
                          listener: (context, state) {},
                          builder: (context, state) {
                            if (state is GetCartProgress || state is GetCartInitial) {
                              return CartSimmer(width: width!, height: height!);
                            }
                            if (state is GetCartFailure) {
                              return Center(
                                  child: Text(
                                state.errorMessage.toString(),
                                textAlign: TextAlign.center,
                              ));
                            }
                            final cartList = (state as GetCartSuccess).cartModel;
                            return Container(
                              margin: EdgeInsets.only(top: height! / 30.0),
                              decoration: DesignConfig.boxCurveShadow(),
                              width: width,
                              child: Container(
                                margin: EdgeInsets.only(left: width! / 20.0, right: width! / 20.0, top: height! / 60.0),
                                child: SingleChildScrollView(
                                  child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                    Row(children: [
                                      Text(
                                        StringsRes.paymentMethod,
                                        style: const TextStyle(fontSize: 14, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500),
                                      ),
                                      const Spacer(),
                                    ]),
                                    Padding(
                                      padding: EdgeInsets.only(top: height! / 80.0, bottom: height! / 50.0),
                                      child: Divider(
                                        color: ColorsRes.lightFont.withOpacity(0.50),
                                        height: 1.0,
                                      ),
                                    ),
                                    Card(
                                      elevation: 0,
                                      child: context.read<SystemConfigCubit>().getWallet() != "0" &&
                                              context.read<SystemConfigCubit>().getWallet().isNotEmpty &&
                                              context.read<SystemConfigCubit>().getWallet() != ""
                                          ? Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                              child: CheckboxListTile(
                                                dense: true,
                                                activeColor: ColorsRes.red,
                                                contentPadding: const EdgeInsets.all(0),
                                                value: isUseWallet,
                                                onChanged: (bool? value) {
                                                  if (mounted) {
                                                    setState(() {
                                                      isUseWallet = value;
                                                      if (value!) {
                                                        if (finalTotal <= double.parse(context.read<SystemConfigCubit>().getWallet())) {
                                                          remWalBal = (double.parse(context.read<SystemConfigCubit>().getWallet()) - finalTotal);
                                                          walletBalanceUsed = finalTotal;
                                                          paymentMethod = "Wallet";

                                                          isPayLayShow = false;
                                                        } else {
                                                          remWalBal = 0;
                                                          walletBalanceUsed = double.parse(context.read<SystemConfigCubit>().getWallet());
                                                          isPayLayShow = true;
                                                        }

                                                        finalTotal = finalTotal - walletBalanceUsed;
                                                      } else {
                                                        finalTotal = finalTotal + walletBalanceUsed;
                                                        remWalBal = double.parse(context.read<SystemConfigCubit>().getWallet());
                                                        paymentMethod = '';
                                                        selectedMethod = null;
                                                        walletBalanceUsed = 0;
                                                        isPayLayShow = true;
                                                      }
                                                    });
                                                  }
                                                },
                                                title: Row(
                                                  children: [
                                                    SvgPicture.asset(DesignConfig.setSvgPath("wallet_icon")),
                                                    Text(
                                                      StringsRes.useWallet,
                                                      style:
                                                          const TextStyle(fontSize: 14, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                                subtitle: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: Text(
                                                    isUseWallet!
                                                        ? StringsRes.remainingBalance +
                                                            " : " +
                                                            context.read<SystemConfigCubit>().getCurrency() +
                                                            " " +
                                                            remWalBal.toStringAsFixed(2)
                                                        : StringsRes.totalBalance +
                                                            " : " +
                                                            context.read<SystemConfigCubit>().getCurrency() +
                                                            " " +
                                                            double.parse(context.read<SystemConfigCubit>().getWallet()).toStringAsFixed(2),
                                                    style:
                                                        const TextStyle(fontSize: 14, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                    ),
                                    isPayLayShow!
                                        ? ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: paymentMethodList.length,
                                            itemBuilder: (context, index) {
                                              //print(paymentMethodList.length);
                                              if (index == 1 && cod) {
                                                return paymentItem(index);
                                              } else if (index == 2 && paypal) {
                                                return paymentItem(index);
                                              } else if (index == 3 && paumoney) {
                                                return paymentItem(index);
                                              } else if (index == 4 && razorpay) {
                                                return paymentItem(index);
                                              } else if (index == 5 && paystack) {
                                                return paymentItem(index);
                                              } else if (index == 6 && flutterwave) {
                                                return paymentItem(index);
                                              } else if (index == 7 && stripe) {
                                                return paymentItem(index);
                                              } else if (index == 8 && paytm) {
                                                return paymentItem(index);
                                              } else if (index == 0 && gpay) {
                                                return paymentItem(index);
                                              } else {
                                                return Container();
                                              }
                                            })
                                        : Container(),
                                    Row(children: [
                                      Text(
                                        StringsRes.deliveryLocation,
                                        style: const TextStyle(fontSize: 14, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500),
                                      ),
                                      const Spacer(),
                                    ]),
                                    Padding(
                                      padding: EdgeInsets.only(top: height! / 80.0, bottom: height! / 50.0),
                                      child: Divider(
                                        color: ColorsRes.lightFont.withOpacity(0.50),
                                        height: 1.0,
                                      ),
                                    ),
                                    deliveryLocation(),
                                    Row(children: [
                                      Text(
                                        StringsRes.payUsing,
                                        style: const TextStyle(fontSize: 14, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.all(3.0),
                                        decoration: DesignConfig.boxDecorationContainer(ColorsRes.textFieldBackground, 4.0),
                                        child: Text(
                                          paymentMethod!,
                                          style: const TextStyle(fontSize: 12, color: ColorsRes.red),
                                        ),
                                      ),
                                    ]),
                                    Padding(
                                      padding: EdgeInsets.only(top: height! / 80.0, bottom: height! / 80.0),
                                      child: Divider(
                                        color: ColorsRes.lightFont.withOpacity(0.50),
                                        height: 1.0,
                                      ),
                                    ),
                                    TextButton(
                                        style: TextButton.styleFrom(
                                          splashFactory: NoSplash.splashFactory,
                                        ),
                                        onPressed: () {
                                          if (paymentMethod == null || paymentMethod!.isEmpty) {
                                            UiUtils.setSnackBar(StringsRes.payment, StringsRes.selectPaymentMethod, context, false);
                                          } else {
                                            doPayment();
                                          }
                                        },
                                        child: Container(
                                            height: height! / 15.0,
                                            margin: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0, bottom: height! / 55.0),
                                            width: width,
                                            padding: EdgeInsets.only(
                                                top: height! / 99.0, bottom: height! / 99.0, left: width! / 20.0, right: width! / 20.0),
                                            decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 100.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(StringsRes.placeOrder,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500)),
                                                Text(
                                                    StringsRes.totalPay +
                                                        " : " +
                                                        context.read<SystemConfigCubit>().getCurrency() +
                                                        (finalTotal + deliveryTip).toString(),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    style: const TextStyle(color: ColorsRes.white, fontSize: 10, fontWeight: FontWeight.w700)),
                                              ],
                                            ))),
                                  ]),
                                ),
                              ),
                            );
                          });
                })));
  }

  Widget paymentItem(int index) {
    return InkWell(
      onTap: () {
        if (mounted) {
          setState(() {
            selectedMethod = index;
            paymentMethod = paymentMethodList[selectedMethod!]!;
            print(paymentMethod.toString() + "Payment");

            paymentModel.forEach((element) => element.isSelected = false);
            paymentModel[index].isSelected = true;
          });
        }
      },
      child: paymentModel.isNotEmpty ? RadioItem(paymentModel[index]) : Container(),
    );
  }
}
