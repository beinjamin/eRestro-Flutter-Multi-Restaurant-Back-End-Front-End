import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:erestro/features/transaction/cubit/transactionCubit.dart';
import 'package:erestro/ui/payment/Stripe_Service.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/ui/payment/payment_radio.dart';
import 'package:erestro/ui/payment/paypal_webview_screen.dart';
import 'package:erestro/ui/widgets/myOrderSimmer.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';
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
import 'package:intl/intl.dart';
import 'package:paytm/paytm.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../utils/internetConnectivity.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  WalletScreenState createState() => WalletScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<TransactionCubit>(
              create: (_) => TransactionCubit(),
              child: const WalletScreen(),
            ));
  }
}

class WalletScreenState extends State<WalletScreen> {
  double? width, height;
  ScrollController controller = ScrollController();
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  TextEditingController? amountController, messageController;
  List<String?> paymentMethodList = [];
  List<String> paymentIconList = [
    'paypal',
    'rozerpay',
    'paystack',
    'flutterwave',
    'stripe',
    'paytm',
  ];
  List<RadioModel> payModel = [];
  bool? paypal, razorpay, paumoney, paystack, flutterwave, stripe, paytm;
  String? razorpayId, payStackId, stripeId, stripeSecret, stripeMode = "test", stripeCurCode, stripePayId, paytmMerId, paytmMerKey;

  int? selectedMethod;
  String? payMethod;
  StateSetter? dialogState;
  bool isProgress = false;
  late Razorpay _razorpay;
  int offset = 0;
  int total = 0;
  bool isLoading = true, payTesting = true;
  final payStackPlugin = PaystackPlugin();
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  String? walletAmount;

  @override
  void initState() {
    super.initState();
    walletAmount = context.read<SystemConfigCubit>().getWallet();
    selectedMethod = null;
    payMethod = null;
    Future.delayed(Duration.zero, () {
      paymentMethodList = [
        StringsRes.payPalLbl,
        StringsRes.razorpayLbl,
        StringsRes.payStackLbl,
        StringsRes.flutterWaveLbl,
        StringsRes.stripeLbl,
        StringsRes.paytmLbl,
      ];
      getPaymentMethod();
    });
    amountController = TextEditingController();
    messageController = TextEditingController();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });
    controller.addListener(scrollListener);
    Future.delayed(Duration.zero, () {
      context.read<TransactionCubit>().fetchTransaction(perPage, context.read<AuthCubit>().getId(), walletKey);
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.initState();
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<TransactionCubit>().hasMoreData()) {
        context.read<TransactionCubit>().fetchMoreTransactionData(perPage, context.read<AuthCubit>().getId(), walletKey);
      }
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    amountController!.dispose();
    messageController!.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> getPaymentMethod() async {
    try {
      var parameter = {
        typeKey: paymentMethodKey,
      };
      Response response = await post(Uri.parse(getSettingsUrl), body: parameter, headers: ApiUtils.getHeaders()).timeout(const Duration(seconds: 50));
      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];

        if (!error) {
          var data = getdata["data"];

          var payment = data["payment_method"];

          paypal = payment["paypal_payment_method"] == "1" ? true : false;
          paumoney = payment["payumoney_payment_method"] == "1" ? true : false;
          flutterwave = payment["flutterwave_payment_method"] == "1" ? true : false;
          razorpay = payment["razorpay_payment_method"] == "1" ? true : false;
          paystack = payment["paystack_payment_method"] == "1" ? true : false;
          stripe = payment["stripe_payment_method"] == "1" ? true : false;
          paytm = payment["paytm_payment_method"] == "1" ? true : false;

          if (razorpay!) razorpayId = payment["razorpay_key_id"];
          if (paystack!) {
            payStackId = payment["paystack_key_id"];

            await payStackPlugin.initialize(publicKey: payStackId!);
          }
          if (stripe!) {
            stripeId = payment['stripe_publishable_key'];
            stripeSecret = payment['stripe_secret_key'];
            stripeCurCode = payment['stripe_currency_code'];
            stripeMode = payment['stripe_mode'] ?? 'test';
          }
          if (paytm!) {
            paytmMerId = payment['paytm_merchant_id'];
            paytmMerKey = payment['paytm_merchant_key'];
            payTesting = payment['paytm_payment_mode'] == 'sandbox' ? true : false;
          }

          for (int i = 0; i < paymentMethodList.length; i++) {
            payModel.add(RadioModel(isSelected: i == selectedMethod ? true : false, name: paymentMethodList[i], img: paymentIconList[i]));
          }
        }
      }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      if (dialogState != null) dialogState!(() {});
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(StringsRes.payment, 'somethingMSg', context, false);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    sendRequest(response.paymentId!, "RazorPay");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    var getdata = json.decode(response.message!);
    String errorMsg = getdata["error"]["description"];

    UiUtils.setSnackBar(errorMsg, errorMsg, context, false);

    if (mounted) {
      isProgress = true;
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  Future<Null> sendRequest(String txnId, String payMethod) async {
    String orderId =
        "wallet-refill-user-${context.read<AuthCubit>().getId()}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}";
    try {
      var parameter = {
        userIdKey: context.read<AuthCubit>().getId(),
        amountKey: amountController!.text.toString(),
        transactionTypeKey: 'wallet',
        typeKey: 'credit',
        messageKey: (messageController!.text == '' || messageController!.text.isEmpty) ? "Added through wallet" : messageController!.text,
        txnIdKey: txnId,
        orderIdKey: orderId,
        statusKey: "Success",
        paymentMethodKey: payMethod.toLowerCase()
      };

      Response response =
          await post(Uri.parse(addTransactionUrl), body: parameter, headers: ApiUtils.getHeaders()).timeout(const Duration(seconds: 50));

      var getdata = json.decode(response.body);
      setState(() {
        walletAmount = getdata['new_balance'];
      });

      bool error = getdata["error"];
      String msg = getdata["message"];

      if (!error) {
        setState(() {
          context.read<SystemConfigCubit>().getSystemConfig(context.read<AuthCubit>().getId());
          context.read<TransactionCubit>().fetchTransaction(perPage, context.read<AuthCubit>().getId(), walletKey);
        });
        //updat wallet balance//
      }
      if (mounted) {
        setState(() {
          isProgress = false;
        });
      }

      UiUtils.setSnackBar(StringsRes.payment, msg, context, false);
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(StringsRes.payment, 'somethingMSg', context, false);

      setState(() {
        isProgress = false;
      });
    }
    return null;
  }

  List<Widget> getPayList() {
    return paymentMethodList
        .asMap()
        .map(
          (index, element) => MapEntry(index, paymentItem(index)),
        )
        .values
        .toList();
  }

  Widget paymentItem(int index) {
    if (index == 0 && paypal! ||
        index == 1 && razorpay! ||
        index == 2 && paystack! ||
        index == 3 && flutterwave! ||
        index == 4 && stripe! ||
        index == 5 && paytm!) {
      return InkWell(
        onTap: () {
          if (mounted) {
            dialogState!(() {
              selectedMethod = index;
              payMethod = paymentMethodList[selectedMethod!];
              payModel.forEach((element) => element.isSelected = false);
              payModel[index].isSelected = true;
            });
          }
        },
        child: RadioItem(payModel[index]),
      );
    } else {
      return Container();
    }
  }

  Future<void> paypalPayment(String amt) async {
    String orderId =
        "wallet-refill-user-${context.read<AuthCubit>().getId()}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}";

    try {
      var parameter = {userIdKey: context.read<AuthCubit>().getId(), orderIdKey: orderId, amountKey: amt};
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
                      from: "wallet",
                      addNote: "",
                    )));
      } else {
        UiUtils.setSnackBar(StringsRes.payment, msg!, context, false);
      }
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(StringsRes.payment, 'somethingMSg', context, false);
    }
  }

  Future<void> flutterWavePayment(String price) async {
    try {
      if (mounted) {
        setState(() {
          isProgress = true;
        });
      }

      var parameter = {
        amountKey: price,
        userIdKey: context.read<AuthCubit>().getId(),
      };
      Response response =
          await post(Uri.parse(flutterwaveWebviewUrl), body: parameter, headers: ApiUtils.getHeaders()).timeout(const Duration(seconds: 50));

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
                        from: "wallet",
                        amt: amountController!.text.toString(),
                        msg: messageController!.text,
                        addNote: "",
                      )));
        } else {
          UiUtils.setSnackBar(StringsRes.payment, msg!, context, false);
        }
        setState(() {
          isProgress = false;
        });
      }
    } on TimeoutException catch (_) {
      setState(() {
        isProgress = false;
      });

      UiUtils.setSnackBar(StringsRes.payment, 'somethingMSg', context, false);
    }
  }

  razorpayPayment(double price) async {
    String? contact = context.read<SystemConfigCubit>().getMobile();
    String? email = context.read<SystemConfigCubit>().getEmail();
    String? name = context.read<SystemConfigCubit>().getName();

    double amt = price * 100;

    if (contact != '' && email != '') {
      if (mounted) {
        setState(() {
          isProgress = true;
        });
      }

      var options = {
        key: razorpayId,
        amountKey: amt,
        nameKey: name,
        'prefill': {contactKey: contact, emailKey: email},
      };

      try {
        _razorpay.open(options);
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

  void paytmPayment(double price) async {
    String? payment_response;
    setState(() {
      isProgress = true;
    });
    String orderId = DateTime.now().millisecondsSinceEpoch.toString();

    String callBackUrl = (payTesting ? 'https://securegw-stage.paytm.in' : 'https://securegw.paytm.in') + '/theia/paytmCallback?ORDER_ID=' + orderId;

    var parameter = {amountKey: price.toString(), userIdKey: context.read<AuthCubit>().getId(), orderIdKey: orderId};

    try {
      final response = await post(
        Uri.parse(generatePaytmTxnTokenUrl),
        body: parameter,
        headers: ApiUtils.getHeaders(),
      );
      var getdata = json.decode(response.body);
      String? txnToken;
      setState(() {
        txnToken = getdata["txn_token"];
      });

      var paytmResponse = Paytm.payWithPaytm(
          callBackUrl: callBackUrl, mId: paytmMerId!, orderId: orderId, txnToken: txnToken!, txnAmount: price.toString(), staging: payTesting);

      paytmResponse.then((value) {
        setState(() {
          isProgress = false;

          if (value['error']) {
            payment_response = value['errorMessage'];
          } else {
            if (value['response'] != null) {
              payment_response = value['response']['STATUS'];
              if (payment_response == "TXN_SUCCESS") {
                sendRequest(orderId, "Paytm");
              }
            }
          }

          UiUtils.setSnackBar(StringsRes.payment, payment_response!, context, false);
        });
      });
    } catch (e) {
      print(e);
    }
  }

  stripePayment(int price) async {
    if (mounted) {
      setState(() {
        isProgress = true;
      });
    }

    var response = await StripeService.payWithPaymentSheet(amount: (price * 100).toString(), currency: stripeCurCode, from: "wallet");

    if (mounted) {
      setState(() {
        isProgress = false;
      });
    }

    UiUtils.setSnackBar(StringsRes.payment, response.message!, context, false);
  }

  payStackPayment(BuildContext context, int price) async {
    if (mounted) {
      setState(() {
        isProgress = true;
      });
    }
    await payStackPlugin.initialize(publicKey: payStackId!);
    String? email = context.read<SystemConfigCubit>().getEmail();

    Charge charge = Charge()
      ..amount = price
      ..reference = _getReference()
      ..email = email;

    try {
      CheckoutResponse response = await payStackPlugin.checkout(
        context,
        method: CheckoutMethod.card,
        charge: charge,
      );

      if (response.status) {
        sendRequest(response.reference!, "Paystack");
      } else {
        UiUtils.setSnackBar(StringsRes.payment, response.message, context, false);
        if (mounted) {
          setState(() {
            isProgress = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => isProgress = false);
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

  Widget wallet() {
    return BlocConsumer<TransactionCubit, TransactionState>(
        bloc: context.read<TransactionCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is TransactionProgress || state is TransactionInitial) {
            return MyOrderSimmer(length: 5, width: width, height: height);
          }
          if (state is TransactionFailure) {
            return Center(
                child: Text(
              state.errorMessageCode.toString(),
              textAlign: TextAlign.center,
            ));
          }

          final transactionList = (state as TransactionSuccess).transactionList;
          final hasMore = state.hasMore;
          return Container(
              height: height! / 1.2,
              color: ColorsRes.white,
              child: ListView.builder(
                  shrinkWrap: true,
                  controller: controller,
                  physics: const BouncingScrollPhysics(),
                  itemCount: transactionList.length,
                  itemBuilder: (BuildContext context, index) {
                    return hasMore && index == (transactionList.length - 1)
                        ? const Center(child: CircularProgressIndicator(color: ColorsRes.red))
                        : GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.only(
                                left: width! / 40.0,
                                top: height! / 99.0,
                                right: width! / 40.0,
                              ),
                              //height: height!/4.7,
                              width: width!,
                              margin: EdgeInsets.only(top: height! / 52.0, left: width! / 40.0, right: width! / 40.0),
                              decoration: DesignConfig.boxDecorationContainerCardShadow(
                                  ColorsRes.white, ColorsRes.shadowBottomBar, 15.0, 0.0, 0.0, 10.0, 0.0),
                              child: Padding(
                                padding: EdgeInsets.only(left: width! / 60.0),
                                child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.end, children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(StringsRes.amount + " : ",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                          SizedBox(width: width! / 99.0),
                                          Text(transactionList[index].amount!,
                                              textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12)),
                                        ],
                                      ),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(StringsRes.date + " :",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                          SizedBox(width: width! / 99.0),
                                          Text(formatter.format(DateTime.parse(transactionList[index].dateCreated!)),
                                              textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12)),
                                        ],
                                      ),
                                      SizedBox(height: height! / 99.0),
                                    ],
                                  ),
                                  SizedBox(height: height! / 99.0),
                                  Row(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(StringsRes.id + " : ",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                          SizedBox(width: width! / 99.0),
                                          Text(transactionList[index].id!,
                                              textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12)),
                                        ],
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.only(top: 4.5, bottom: 4.5),
                                            width: 55,
                                            decoration: DesignConfig.boxDecorationContainer(
                                                transactionList[index].status == StringsRes.success ? ColorsRes.green : ColorsRes.red, 4.0),
                                            child: Text(
                                              transactionList[index].status!,
                                              style: const TextStyle(fontSize: 10, color: ColorsRes.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height! / 99.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(StringsRes.type + " : ",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                      SizedBox(width: width! / 99.0),
                                      Text(transactionList[index].type!,
                                          textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12)),
                                    ],
                                  ),
                                  SizedBox(height: height! / 99.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(StringsRes.message + " :",
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                      SizedBox(width: width! / 99.0),
                                      SizedBox(
                                          width: width! / 1.7,
                                          child: Text(transactionList[index].message!,
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                  SizedBox(height: height! / 99.0),
                                ]),
                              ),
                            ),
                          );
                  }));
        });
  }

  showDialog() async {
    bool payWarn = false;
    await dialogAnimate(context, StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
      dialogState = setStater;
      return AlertDialog(
        contentPadding: const EdgeInsets.all(0.0),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
        content: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
              child: Text(
                StringsRes.addMoney,
                style: Theme.of(this.context).textTheme.subtitle1!.copyWith(color: ColorsRes.lightFontColor),
              )),
          const Divider(color: ColorsRes.lightFont),
          Form(
            key: _formkey,
            child: Flexible(
              child: SingleChildScrollView(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: <Widget>[
                Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                    child: TextFormField(
                      style: Theme.of(this.context).textTheme.subtitle1!.copyWith(color: ColorsRes.lightFont, fontWeight: FontWeight.normal),
                      keyboardType: TextInputType.number,
                      validator: (val) => validateField(val!, StringsRes.requirdField),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        hintText: StringsRes.amount,
                        hintStyle:
                            Theme.of(this.context).textTheme.subtitle1!.copyWith(color: ColorsRes.lightFontColor, fontWeight: FontWeight.normal),
                      ),
                      controller: amountController,
                    )),
                Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                    child: TextFormField(
                      style: Theme.of(this.context).textTheme.subtitle1!.copyWith(color: ColorsRes.lightFontColor, fontWeight: FontWeight.normal),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        hintText: StringsRes.message,
                        hintStyle:
                            Theme.of(this.context).textTheme.subtitle1!.copyWith(color: ColorsRes.lightFontColor, fontWeight: FontWeight.normal),
                      ),
                      controller: messageController,
                    )),
                //Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 10, 20.0, 5),
                  child: Text(
                    StringsRes.payment,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ),
                const Divider(),
                payWarn
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'payWarning',
                          style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
                        ),
                      )
                    : Container(),

                paypal == null
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: ColorsRes.red,
                      ))
                    : Column(mainAxisAlignment: MainAxisAlignment.start, children: getPayList()),
              ])),
            ),
          )
        ]),
        actions: <Widget>[
          TextButton(
              style: TextButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
              ),
              child: Text(
                StringsRes.cancel,
                style: Theme.of(this.context).textTheme.subtitle2!.copyWith(color: ColorsRes.red, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          TextButton(
              style: TextButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
              ),
              child: Text(
                StringsRes.send,
                style: Theme.of(this.context).textTheme.subtitle2!.copyWith(color: ColorsRes.red, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                final form = _formkey.currentState!;
                if (form.validate() && amountController!.text != '0') {
                  form.save();
                  if (payMethod == null) {
                    dialogState!(() {
                      payWarn = true;
                    });
                  } else {
                    if (payMethod!.trim() == StringsRes.stripeLbl) {
                      stripePayment(int.parse(amountController!.text));
                    } else if (payMethod!.trim() == StringsRes.razorpayLbl) {
                      razorpayPayment(double.parse(amountController!.text));
                    } else if (payMethod!.trim() == StringsRes.payStackLbl) {
                      payStackPayment(context, int.parse(amountController!.text));
                    } else if (payMethod == StringsRes.paytmLbl) {
                      paytmPayment(double.parse(amountController!.text));
                    } else if (payMethod == StringsRes.payPalLbl) {
                      paypalPayment((amountController!.text).toString());
                    } else if (payMethod == StringsRes.flutterWaveLbl) {
                      flutterWavePayment(amountController!.text);
                    }
                    Navigator.pop(context);
                  }
                }
              })
        ],
      );
    }));
  }

  Future<void> refreshList() async {
    context.read<TransactionCubit>().fetchTransaction(perPage, context.read<AuthCubit>().getId(), walletKey);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return BlocListener<SystemConfigCubit, SystemConfigState>(
      bloc: context.read<SystemConfigCubit>(),
      listener: (context, state) {
        if (state is SystemConfigFetchSuccess) {
          context.read<SystemConfigCubit>().getSystemConfig(context.read<AuthCubit>().getId());
        }
        if (state is SystemConfigFetchFailure) {
          print(state.errorCode);
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
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
                  title: Text(StringsRes.wallet,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                  bottom: PreferredSize(
                    preferredSize: Size(width!, height! / 5.5),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Card(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(DesignConfig.setSvgPath("wallet_icon")),
                                  Text(
                                    " " + StringsRes.currentBalance,
                                    style:
                                        Theme.of(context).textTheme.subtitle2!.copyWith(color: ColorsRes.backgroundDark, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Text(context.read<SystemConfigCubit>().getCurrency() + walletAmount! /*.toStringAsFixed(2)*/,
                                  style:
                                      Theme.of(context).textTheme.headline6!.copyWith(color: ColorsRes.backgroundDark, fontWeight: FontWeight.bold)),
                              TextButton(
                                  style: TextButton.styleFrom(
                                    splashFactory: NoSplash.splashFactory,
                                  ),
                                  onPressed: () {
                                    showDialog();
                                  },
                                  child: Container(
                                      margin: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0),
                                      width: width,
                                      padding:
                                          EdgeInsets.only(top: height! / 55.0, bottom: height! / 55.0, left: width! / 20.0, right: width! / 20.0),
                                      decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 100.0),
                                      child: Text(StringsRes.addMoney,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500))))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                body: Container(
                  margin: EdgeInsets.only(top: height! / 50.0),
                  decoration: DesignConfig.boxCurveShadow(),
                  width: width,
                  child: Container(
                      color: ColorsRes.white,
                      margin: EdgeInsets.only(left: width! / 20.0, right: width! / 20.0, top: height! / 60.0),
                      child: RefreshIndicator(onRefresh: refreshList, color: ColorsRes.red, child: wallet())),
                ),
              ),
      ),
    );
  }
}

dialogAnimate(BuildContext context, Widget dialge) {
  return showGeneralDialog(
      barrierColor: ColorsRes.backgroundDark,
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(opacity: a1.value, child: dialge),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      // pageBuilder: null
      pageBuilder: (context, animation1, animation2) {
        return Container();
      } //as Widget Function(BuildContext, Animation<double>, Animation<double>)
      );
}

String? validateField(String value, String? msg) {
  if (value.length == 0) {
    return msg;
  } else {
    return null;
  }
}
