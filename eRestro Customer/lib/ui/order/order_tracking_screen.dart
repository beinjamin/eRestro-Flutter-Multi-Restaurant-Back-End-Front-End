import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/app/routes.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/order/cubit/orderCubit.dart';
import 'package:erestro/features/order/cubit/orderLiveTrackingCubit.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../utils/internetConnectivity.dart';
import 'dart:ui' as ui;

class OrderTrackingScreen extends StatefulWidget {
  final String? id, riderId, riderName, riderRating, riderImage, riderMobile, riderNoOfRating, orderAddress, partnerAddress;
  final double? latitude, longitude, latitudeRes, longitudeRes;
  const OrderTrackingScreen(
      {Key? key,
      this.id,
      this.riderId,
      this.riderName,
      this.riderRating,
      this.riderImage,
      this.riderMobile,
      this.riderNoOfRating,
      this.latitude,
      this.longitude,
      this.orderAddress,
      this.partnerAddress,
      this.latitudeRes,
      this.longitudeRes})
      : super(key: key);

  @override
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<OrderCubit>(
              create: (_) => OrderCubit(),
              child: OrderTrackingScreen(
                  id: arguments['id'] as String,
                  riderName: arguments['riderName'] as String,
                  riderRating: arguments['riderRating'] as String,
                  riderImage: arguments['riderImage'] as String,
                  riderMobile: arguments['riderMobile'] as String,
                  riderNoOfRating: arguments['riderNoOfRating'] as String,
                  latitude: arguments['latitude'] as double,
                  longitude: arguments['longitude'] as double,
                  latitudeRes: arguments['latitudeRes'] as double,
                  longitudeRes: arguments['longitudeRes'] as double,
                  orderAddress: arguments['orderAddress'] as String,
                  partnerAddress: arguments['partnerAddress'] as String),
            ));
  }
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  LatLng? latlong = null;
  late CameraPosition _cameraPosition;
  TextEditingController locationController = TextEditingController();
  double? width, height;
  String? locationStatus = StringsRes.office;
  late Position position;
  TextEditingController areaRoadApartmentNameController = TextEditingController(text: "");
  TextEditingController houseFlatNoController = TextEditingController(text: "");
  TextEditingController additionalInstructionsController = TextEditingController(text: "");
  TextEditingController alternateMobileNumberController = TextEditingController(text: "");
  TextEditingController landmarkController = TextEditingController(text: "");
  String? states, country, pincode, latitude, longitude, address, city;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String? orderStatus = "";
  Timer? timer;
  late GoogleMapController mapController;
  double? _originLatitude, _originLongitude;
  double? _destLatitude, _destLongitude;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  late LatLng deliveryBoyLocation = const LatLng(0, 0);
  late PolylineId polylineId;
  ScrollController orderController = ScrollController();
  BitmapDescriptor? driverIcon, restaurantsIcon, destinationIcon;

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<BitmapDescriptor> bitmapDescriptorFromSvgAsset(BuildContext context, String assetName) async {
    // Read SVG file as String
    String svgString = await DefaultAssetBundle.of(context).loadString(assetName);
    // Create DrawableRoot from SVG String
    DrawableRoot svgDrawableRoot = await svg.fromSvgString(svgString, 'marker');

    // toPicture() and toImage() don't seem to be pixel ratio aware, so we calculate the actual sizes here
    MediaQueryData queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;

    //double width = 50 * devicePixelRatio;
    //double height = 50 * devicePixelRatio;
    double width = 32 * devicePixelRatio;
    double height = 32 * devicePixelRatio;

    // Convert to ui.Picture
    ui.Picture picture = svgDrawableRoot.toPicture(size: Size(width, height));

    // Convert to ui.Image. toImage() takes width and height as parameters
    // you need to find the best size to suit your needs and take into account the
    // screen DPI
    ui.Image image = await picture.toImage(width.toInt(), height.toInt());
    ByteData? bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  @override
  void initState() {
    super.initState();
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });
    print("Data:" +
        widget.id.toString() +
        widget.riderName.toString() +
        widget.riderRating.toString() +
        widget.riderImage.toString() +
        widget.riderMobile.toString() +
        widget.riderNoOfRating.toString() +
        widget.latitude.toString() +
        widget.longitude.toString() +
        widget.latitudeRes.toString() +
        widget.longitudeRes.toString() +
        widget.orderAddress.toString() +
        widget.partnerAddress.toString());
    orderLiveTracking();
    _destLatitude = widget.latitude!;
    _destLongitude = widget.longitude!;
    _cameraPosition = const CameraPosition(target: LatLng(0, 0), zoom: 10.0);
    orderController.addListener(orderScrollListener);
    Future.delayed(Duration.zero, () {
      context.read<OrderCubit>().fetchOrder(perPage, context.read<AuthCubit>().getId(), widget.id!);
    });

    /// destination marker
    _addMarker(LatLng(_destLatitude!, _destLongitude!), "destination", 1);

    /// Current restaurant
    _addMarker(LatLng(widget.latitudeRes!, widget.longitudeRes!), "restaurant", 2);

    _getPolylineBetweenRestaurantToCustomer();
  }

  void orderLiveTracking() {
    timer = Timer.periodic(const Duration(seconds: 2), (Timer t) async {
      context.read<OrderLiveTrackingCubit>().getOrderLiveTracking(orderId: widget.id!);
      _getPolylineBetweenRestaurantToDeliveryBoy();
    });
  }

  orderScrollListener() {
    if (orderController.position.maxScrollExtent == orderController.offset) {
      if (context.read<OrderCubit>().hasMoreData()) {
        context.read<OrderCubit>().fetchMoreOrderData(perPage, context.read<AuthCubit>().getId(), widget.id!);
      }
    }
  }

  @override
  void dispose() {
    timer!.cancel();
    locationController.dispose();
    areaRoadApartmentNameController.dispose();
    houseFlatNoController.dispose();
    additionalInstructionsController.dispose();
    alternateMobileNumberController.dispose();
    landmarkController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return _connectionStatus == 'ConnectivityResult.none'
        ? const NoInternetScreen()
        : Scaffold(
            body: BlocConsumer<OrderLiveTrackingCubit, OrderLiveTrackingState>(
                bloc: context.read<OrderLiveTrackingCubit>(),
                listener: (context, state) {
                  if (state is OrderLiveTrackingSuccess) {
                    _originLatitude = double.parse(state.orderLiveTracking.latitude!);
                    _originLongitude = double.parse(state.orderLiveTracking.longitude!);
                    orderStatus = state.orderLiveTracking.orderStatus;
                    if (orderStatus == deliveredKey) {
                      Future.delayed(Duration.zero, () {
                        Navigator.of(context).pushReplacementNamed(Routes.home, arguments: false);
                      });
                    }
                    print("OderStatus:" + orderStatus.toString());
                    _addMarker(LatLng(_originLatitude!, _originLongitude!), "origin", 0);
                    updateMarker(LatLng(_originLatitude!, _originLongitude!), "origin");
                  }
                },
                builder: (context, state) {
                  if (state is OrderLiveTrackingProgress || state is OrderLiveTrackingInitial) {
                    return const Center(
                      child: CircularProgressIndicator(color: ColorsRes.red),
                    );
                  }
                  if (state is OrderLiveTrackingFailure) {
                    return Center(
                        child: Text(
                      state.errorMessage.toString(),
                      textAlign: TextAlign.center,
                    ));
                  }
                  final orderLiveTracingList = (state as OrderLiveTrackingSuccess).orderLiveTracking;
                  return BlocConsumer<OrderCubit, OrderState>(
                      bloc: context.read<OrderCubit>(),
                      listener: (context, state) {},
                      builder: (context, state) {
                        if (state is OrderProgress || state is OrderInitial) {
                          return const Center(
                            child: CircularProgressIndicator(color: ColorsRes.red),
                          );
                        }
                        if (state is OrderFailure) {
                          return Center(
                              child: Text(
                            state.errorMessageCode.toString(),
                            textAlign: TextAlign.center,
                          ));
                        }
                        final orderList = (state as OrderSuccess).orderList;
                        return Stack(
                          children: [
                            Container(
                              height: height! / 1.8,
                              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                              child: _originLatitude != null && _originLongitude != null
                                  ? GoogleMap(
                                      initialCameraPosition: CameraPosition(target: LatLng(_originLatitude!, _originLongitude!), zoom: 14.0),
                                      myLocationEnabled: true,
                                      tiltGesturesEnabled: true,
                                      compassEnabled: true,
                                      scrollGesturesEnabled: true,
                                      zoomGesturesEnabled: true,
                                      onMapCreated: _onMapCreated,
                                      mapType: MapType.normal,
                                      markers: Set<Marker>.of(markers.values),
                                      polylines: Set<Polyline>.of(polylines.values),
                                    )
                                  : Container(),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                margin: EdgeInsets.only(top: height! / 2.0),
                                decoration: DesignConfig.boxDecorationContainerHalf(ColorsRes.red),
                                width: width,
                                height: height!,
                                child: SingleChildScrollView(
                                  child: Stack(
                                    children: [
                                      Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        SizedBox(height: height! / 30.0),
                                        Padding(
                                          padding: EdgeInsets.only(left: width! / 25.0),
                                          child: Row(
                                            children: [
                                              Container(
                                                  width: 32.0,
                                                  height: 32.0,
                                                  margin: EdgeInsets.only(left: width! / 40.0, top: height! / 99.0, right: width! / 40.0),
                                                  decoration: DesignConfig.boxDecorationContainerCardShadow(
                                                      ColorsRes.white, ColorsRes.shadowCard, 5, 0, 3, 6, 0),
                                                  child: SvgPicture.asset(DesignConfig.setSvgPath("other_address"), fit: BoxFit.scaleDown)),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(StringsRes.deliveryFrom,
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                          color: ColorsRes.white.withOpacity(0.69), fontSize: 10, fontWeight: FontWeight.w500)),
                                                  SizedBox(
                                                      width: width! / 1.6,
                                                      child: Text(widget.partnerAddress!,
                                                          textAlign: TextAlign.start,
                                                          style: const TextStyle(color: ColorsRes.white, fontSize: 10, fontWeight: FontWeight.w500))),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          height: height! / 15.0,
                                          width: 2.0,
                                          margin: EdgeInsets.only(left: width! / 9.0),
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              physics: const AlwaysScrollableScrollPhysics(),
                                              itemCount: 20,
                                              itemBuilder: (BuildContext context, index) {
                                                return Container(
                                                  margin: const EdgeInsets.only(top: 2.0),
                                                  height: 5.0,
                                                  width: 2.0,
                                                  color: ColorsRes.white,
                                                );
                                              }),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: width! / 25.0),
                                          child: Row(
                                            children: [
                                              Container(
                                                  width: 32.0,
                                                  height: 32.0,
                                                  margin: EdgeInsets.only(left: width! / 40.0, bottom: height! / 99.0, right: width! / 40.0),
                                                  decoration: DesignConfig.boxDecorationContainerCardShadow(
                                                      ColorsRes.white, ColorsRes.shadowCard, 5, 0, 3, 6, 0),
                                                  child: SvgPicture.asset(DesignConfig.setSvgPath("other_address"), fit: BoxFit.scaleDown)),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(StringsRes.deliveryLocation,
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                          color: ColorsRes.white.withOpacity(0.69), fontSize: 10, fontWeight: FontWeight.w500)),
                                                  SizedBox(
                                                      width: width! / 1.6,
                                                      child: Text(
                                                        widget.orderAddress!,
                                                        textAlign: TextAlign.start,
                                                        style: const TextStyle(color: ColorsRes.white, fontSize: 10, fontWeight: FontWeight.w500),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      )),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]),
                                      Container(
                                        margin: EdgeInsets.only(top: height! / 4.5),
                                        decoration: DesignConfig.boxDecorationContainerHalf(ColorsRes.white),
                                        width: width,
                                        height: height!,
                                        child: SingleChildScrollView(
                                          physics: const NeverScrollableScrollPhysics(),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: height! / 30.0),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: height! / 70.0, bottom: height! / 70.0, left: width! / 20.0, right: width! / 20.0),
                                                child: Divider(
                                                  color: ColorsRes.lightFont.withOpacity(0.50),
                                                  height: 1.0,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: width! / 20.0,
                                                  right: width! / 20.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(StringsRes.orderId,
                                                        textAlign: TextAlign.start,
                                                        style:
                                                            const TextStyle(color: ColorsRes.lightFont, fontSize: 14, fontWeight: FontWeight.w500)),
                                                    const Spacer(),
                                                    Text(orderList[0].id!,
                                                        textAlign: TextAlign.start,
                                                        style: const TextStyle(
                                                            color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: height! / 70.0, bottom: height! / 70.0, left: width! / 20.0, right: width! / 20.0),
                                                child: Divider(
                                                  color: ColorsRes.lightFont.withOpacity(0.50),
                                                  height: 1.0,
                                                ),
                                              ),
                                              Container(
                                                height: 15.0,
                                                width: 15.0,
                                                margin: EdgeInsets.only(left: width! / 11.0),
                                                decoration: DesignConfig.boxDecorationCircle(ColorsRes.red, ColorsRes.white, 100.0),
                                              ),
                                              Container(
                                                  height: height! / 2.37,
                                                  width: width!,
                                                  margin: EdgeInsets.only(left: width! / 40.0 /*, bottom: height!/50.0*/),
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      padding: EdgeInsets.zero,
                                                      physics: const NeverScrollableScrollPhysics(),
                                                      itemCount: orderList[0].status!.length,
                                                      scrollDirection: Axis.vertical,
                                                      itemBuilder: (BuildContext context, index) {
                                                        var status = "";
                                                        if (orderList[0].status![index][0] == deliveredKey) {
                                                          status = StringsRes.delivered;
                                                        } else if (orderList[0].status![index][0] == pendingKey) {
                                                          status = StringsRes.pendingLb;
                                                        } else if (orderList[0].status![index][0] == waitingKey) {
                                                          status = StringsRes.pendingLb;
                                                        } else if (orderList[0].status![index][0] == receivedKey) {
                                                          status = StringsRes.pendingLb;
                                                        } else if (orderList[0].status![index][0] == outForDeliveryKey) {
                                                          status = StringsRes.outForDeliveryLb;
                                                        } else if (orderList[0].status![index][0] == confirmedKey) {
                                                          status = StringsRes.confirmedLb;
                                                        } else if (orderList[0].status![index][0] == cancelledKey) {
                                                          status = StringsRes.cancel;
                                                        } else if (orderList[0].status![index][0] == preparingKey) {
                                                          status = StringsRes.preparingLb;
                                                        } else {
                                                          status = "";
                                                        }
                                                        return InkWell(
                                                            splashFactory: NoSplash.splashFactory,
                                                            onTap: () {},
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Container(
                                                                  height: height! / 20.0,
                                                                  width: 2.0,
                                                                  margin: EdgeInsets.only(left: width! / 12.0),
                                                                  child: ListView.builder(
                                                                      shrinkWrap: true,
                                                                      padding: EdgeInsets.zero,
                                                                      physics: const NeverScrollableScrollPhysics(),
                                                                      itemCount: 20,
                                                                      itemBuilder: (BuildContext context, index) {
                                                                        return Container(
                                                                          margin: const EdgeInsets.only(top: 2.0),
                                                                          height: 5.0,
                                                                          width: 2.0,
                                                                          color: ColorsRes.backgroundDark,
                                                                        );
                                                                      }),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Container(
                                                                          margin: EdgeInsets.only(right: width! / 50.0),
                                                                          alignment: Alignment.center,
                                                                          height: 40.0,
                                                                          width: 40,
                                                                          decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 10.0),
                                                                          child: const Icon(Icons.check, color: ColorsRes.white)),
                                                                      SizedBox(
                                                                        height: height! / 18.0,
                                                                        child: Column(
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          children: [
                                                                            Text(StringsRes.order + " " + status,
                                                                                textAlign: TextAlign.start,
                                                                                style: const TextStyle(
                                                                                    color: ColorsRes.backgroundDark,
                                                                                    fontSize: 12,
                                                                                    fontWeight: FontWeight.w500)),
                                                                            const SizedBox(height: 1.0),
                                                                            Text(StringsRes.yourOrder + " " + status,
                                                                                textAlign: TextAlign.start,
                                                                                style: const TextStyle(
                                                                                    color: ColorsRes.lightFont,
                                                                                    fontSize: 10,
                                                                                    fontWeight: FontWeight.w500)),
                                                                            const SizedBox(height: 1.0),
                                                                            Text(orderList[0].status![index][1],
                                                                                textAlign: TextAlign.start,
                                                                                style: const TextStyle(
                                                                                    color: ColorsRes.lightFont,
                                                                                    fontSize: 10,
                                                                                    fontWeight: FontWeight.w500)),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ));
                                                      })),
                                              Container(
                                                height: height! / 20.0,
                                                width: 2.0,
                                                margin: EdgeInsets.only(left: width! / 9.0),
                                                child: ListView.builder(
                                                    shrinkWrap: true,
                                                    padding: EdgeInsets.zero,
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    itemCount: 20,
                                                    itemBuilder: (BuildContext context, index) {
                                                      return Container(
                                                        margin: const EdgeInsets.only(top: 2.0),
                                                        height: 5.0,
                                                        width: 2.0,
                                                        color: ColorsRes.backgroundDark,
                                                      );
                                                    }),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(left: width! / 20.0, right: width! / 40.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                        margin: EdgeInsets.only(right: width! / 50.0),
                                                        alignment: Alignment.center,
                                                        height: 40.0,
                                                        width: 40,
                                                        decoration: DesignConfig.boxDecorationContainer(ColorsRes.lightFont, 10.0),
                                                        child: const Icon(Icons.check, color: ColorsRes.white)),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        SizedBox(
                                                          height: height! / 18.0,
                                                          child: Row(
                                                            children: [
                                                              Column(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Text(StringsRes.order + " " + StringsRes.delivery,
                                                                      textAlign: TextAlign.start,
                                                                      style: const TextStyle(
                                                                          color: ColorsRes.backgroundDark,
                                                                          fontSize: 12,
                                                                          fontWeight: FontWeight.w500)),
                                                                  const SizedBox(height: 1.0),
                                                                  Text(StringsRes.yourOrder + " " + StringsRes.delivered,
                                                                      textAlign: TextAlign.start,
                                                                      style: const TextStyle(
                                                                          color: ColorsRes.lightFont, fontSize: 10, fontWeight: FontWeight.w500)),
                                                                  const SizedBox(height: 1.0),
                                                                  //Text(orderList[0].status![index][1], textAlign: TextAlign.start, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 10, fontWeight: FontWeight.w500)),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets.only(left: width! / 4.5),
                                                          height: height! / 18.0,
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets.only(right: width! / 60.0),
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                                  children: [
                                                                    Text(orderList[0].riderName ?? "",
                                                                        textAlign: TextAlign.center,
                                                                        style: const TextStyle(
                                                                            color: ColorsRes.backgroundDark,
                                                                            fontSize: 12,
                                                                            fontWeight: FontWeight.w500)),
                                                                    const SizedBox(height: 5.0),
                                                                    Text(StringsRes.deliveryBoyId + "" + orderList[0].riderId!,
                                                                        textAlign: TextAlign.center,
                                                                        style: const TextStyle(
                                                                            color: ColorsRes.lightFont, fontSize: 12, fontWeight: FontWeight.w500)),
                                                                    // SvgPicture.asset(DesignConfig.setSvgPath(restaurantList[index].status=="1"?"veg_icon" : "non_veg_icon"), width: 15, height: 15),
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                  alignment: Alignment.center,
                                                                  height: 39.0,
                                                                  width: 39.0,
                                                                  decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 10.0),
                                                                  child: const Icon(Icons.person, color: ColorsRes.white)),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    height: height! / 15.0,
                                                    width: 2.0,
                                                    margin: EdgeInsets.only(left: width! / 9.0),
                                                    child: ListView.builder(
                                                        shrinkWrap: true,
                                                        padding: EdgeInsets.zero,
                                                        physics: const NeverScrollableScrollPhysics(),
                                                        itemCount: 20,
                                                        itemBuilder: (BuildContext context, index) {
                                                          return Container(
                                                            margin: const EdgeInsets.only(top: 2.0),
                                                            height: 5.0,
                                                            width: 2.0,
                                                            color: ColorsRes.backgroundDark,
                                                          );
                                                        }),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      launch("tel:" + Uri.encodeComponent(orderList[0].riderMobile!));
                                                    },
                                                    child: Align(
                                                      alignment: Alignment.topRight,
                                                      child: Container(
                                                        width: width! / 3.0,
                                                        margin: EdgeInsets.only(top: height! / 80.0, right: width! / 70.0, left: height! / 4.5),
                                                        padding: const EdgeInsets.all(2.0),
                                                        decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 39.0),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                                child: Text(
                                                              StringsRes.call,
                                                              textAlign: TextAlign.center,
                                                              style: const TextStyle(
                                                                  color: ColorsRes.white,
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.w600,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  letterSpacing: 1.04),
                                                              maxLines: 2,
                                                            )),
                                                            Container(
                                                                height: 26.1,
                                                                width: 26.1,
                                                                decoration: DesignConfig.boxDecorationContainer(ColorsRes.white, 39.0),
                                                                child: const Icon(Icons.call, color: ColorsRes.backgroundDark)),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                height: 15.0,
                                                width: 15.0,
                                                margin: EdgeInsets.only(left: width! / 11.0),
                                                decoration: DesignConfig.boxDecorationCircle(ColorsRes.red, ColorsRes.white, 100.0),
                                              ),
                                              SizedBox(height: height! / 20.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                    padding: EdgeInsets.only(left: width! / 20.0, top: height! / 20.0),
                                    child: SvgPicture.asset(DesignConfig.setSvgPath("back_icon"), width: 32, height: 32))),
                          ],
                        );
                      });
                }));
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    _addPolyLine();
  }

  _addMarker(LatLng position, String id, int status) async {
    MarkerId markerId = MarkerId(id);
    BitmapDescriptor? icon, defaultIcon;
    if (status == 0) {
      //print("Status:"+status.toString());
      driverIcon = await bitmapDescriptorFromSvgAsset(context, DesignConfig.setSvgPath('delivery_boy'));
      defaultIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      icon = driverIcon;
    } else if (status == 1) {
      //print("Status:"+status.toString());
      restaurantsIcon = await bitmapDescriptorFromSvgAsset(context, DesignConfig.setSvgPath('map_pin'));
      defaultIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      icon = restaurantsIcon;
    } else {
      //print("Status:"+status.toString());
      destinationIcon = await bitmapDescriptorFromSvgAsset(context, DesignConfig.setSvgPath('address_icon'));
      defaultIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      icon = destinationIcon;
    }
    setState(() {});
    Marker marker = Marker(markerId: markerId, icon: icon == null ? defaultIcon : icon, position: position);
    markers[markerId] = marker;
  }

  updateMarker(LatLng latLng, String id) async {
    BitmapDescriptor? icon, defaultIcon;
    MarkerId markerId = const MarkerId("origin");
    driverIcon = await bitmapDescriptorFromSvgAsset(context, "assets/images/svg/delivery_boy.svg");
    defaultIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    icon = driverIcon;
    Marker _marker = Marker(
      markerId: markerId,
      position: latLng,
      icon: icon ?? defaultIcon,
    );
    if (mounted) {
      setState(() {
        markers[markerId] = _marker;
      });
    }
  }

  _addPolyLine() {
    PolylineId id = PolylineId(widget.id!);
    Polyline polyline = Polyline(polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  List<LatLng> decodeEncodedPolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());

      poly.add(p);
    }
    return poly;
  }

  Future<List<LatLng>> getRouteBetweenCoordinates(
    LatLng origin,
    LatLng destination,
  ) async {
    List<LatLng> latlnglist = [];
    var params = {
      "origin": "${origin.latitude},${origin.longitude}",
      "destination": "${destination.latitude},${destination.longitude}",
      "mode": 'driving',
      "key": Platform.isIOS ? googleAPiKeyIos : googleAPiKeyAndroid
    };

    Uri uri = Uri.https("maps.googleapis.com", "maps/api/directions/json", params);

    // print('GOOGLE MAPS URL: ' + url);
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      var parsedJson = json.decode(response.body);

      if (parsedJson["status"]?.toLowerCase() == 'ok' && parsedJson["routes"] != null && parsedJson["routes"].isNotEmpty) {
        latlnglist = decodeEncodedPolyline(parsedJson["routes"][0]["overview_polyline"]["points"]);
      }
    }
    return latlnglist;
  }

  _getPolylineBetweenRestaurantToDeliveryBoy() async {
    try {
      if (orderStatus == deliveredKey) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pushReplacementNamed(Routes.home, arguments: false);
        });
      }
      List<LatLng> mainroute = [];
      mainroute = await getRouteBetweenCoordinates(LatLng(widget.latitude!, widget.longitude!), LatLng(_originLatitude!, _originLongitude!));

      if (mainroute.isEmpty) {
        mainroute = [];
        mainroute.add(LatLng(widget.latitude!, widget.longitude!));
        mainroute.add(LatLng(_originLatitude!, _originLongitude!));
      }
      polylineId = PolylineId(widget.id!);
      Polyline polyline = Polyline(
          polylineId: polylineId,
          visible: true,
          points: mainroute,
          color: Colors.red,
          patterns: [PatternItem.dot, PatternItem.gap(10)],
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
          width: 8);
      polylines[polylineId] = polyline;
      //print(data);
      _addMarker(LatLng(_originLatitude!, _originLongitude!), "origin", 0);
      setState(() {});
    } catch (e) {
      print(e.toString());
    }
  }

  _getPolylineBetweenRestaurantToCustomer() async {
    List<LatLng> mainroute = [];
    mainroute = await getRouteBetweenCoordinates(LatLng(widget.latitudeRes!, widget.longitudeRes!), LatLng(widget.latitude!, widget.longitude!));

    if (mainroute.isEmpty) {
      mainroute = [];
      mainroute.add(LatLng(widget.latitudeRes!, widget.longitudeRes!));
      mainroute.add(LatLng(widget.latitude!, widget.longitude!));
    }

    PolylineId polylineId = PolylineId(widget.orderAddress!); //init when order id get that time
    Polyline polyline = Polyline(
        polylineId: polylineId,
        visible: true,
        points: mainroute,
        color: Colors.green,
        patterns: [PatternItem.dot, PatternItem.gap(10)],
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
        width: 8);
    polylines[polylineId] = polyline;

    //
    setState(() {});
  }
}
