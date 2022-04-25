import 'dart:async';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/features/address/addressModel.dart';
import 'package:erestro/features/address/addressRepository.dart';
import 'package:erestro/features/address/cubit/updateAddressCubit.dart';
import 'package:erestro/features/address/cubit/addressCubit.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:erestro/helper/color.dart';

import '../../utils/internetConnectivity.dart';

//String? latitude = "",longitude = "";
class UpdateAddressScreen extends StatefulWidget {
  /*final double? latitude, longitude;
  final String? from, states, country, pincode, address, city, alternateMobileNumbers, area, locationStatus, id;*/
  final AddressModel? addressModel;

  const UpdateAddressScreen({
    Key? key,
    this.addressModel,
    /* this.latitude, this.longitude, this.from, this.states, this.country, this.pincode, this.address, this.city, this.alternateMobileNumbers, this.area, this.locationStatus, this.id*/
  }) : super(key: key);

  @override
  _UpdateAddressScreenState createState() => _UpdateAddressScreenState();
  static Route<UpdateAddressScreen> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<UpdateAddressCubit>(
              create: (_) => UpdateAddressCubit(
                AddressRepository(),
              ),
              child: UpdateAddressScreen(
                  addressModel: arguments[
                      'addressModel'] /*, id: arguments['id'], latitude: arguments['latitude'],longitude: arguments['longitude'], address: arguments['address'] as String, alternateMobileNumbers: arguments['alternateMobileNumbers'] as String, area: arguments['area'] as String, city: arguments['city'] as String, country: arguments['country'] as String, locationStatus: arguments['locationStatus'] as String, pincode: arguments['pincode'] as String, states: arguments['states'] as String*/),
            ));
  }
}

class _UpdateAddressScreenState extends State<UpdateAddressScreen> {
  LatLng? latlong = null;
  late CameraPosition _cameraPosition;
  GoogleMapController? _controller;
  TextEditingController locationController = TextEditingController();
  Set<Marker> _markers = Set();
  double? width, height;
  String? locationStatus;
  late Position position;
  TextEditingController areaRoadApartmentNameController = TextEditingController(text: "");
  TextEditingController addressController = TextEditingController(text: "");
  TextEditingController cityController = TextEditingController(text: "");
  TextEditingController alternateMobileNumberController = TextEditingController(text: "");
  TextEditingController landmarkController = TextEditingController(text: "");
  String? states, country, pincode, latitude, longitude, address, city, area;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  getUserLocation() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();

      getUserLocation();
    } else if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        await Geolocator.openLocationSettings();

        getUserLocation();
      } else {
        getUserLocation();
      }
    } else {
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print("heading---${position.heading}");

      List<Placemark> placemark = await placemarkFromCoordinates(position.latitude, position.longitude, localeIdentifier: "en");
      // print(placemarks[0]);

      if (mounted) {
        setState(() {
          latlong = LatLng(double.parse(widget.addressModel!.latitude!), double.parse(widget.addressModel!.longitude!));

          _cameraPosition = CameraPosition(target: latlong!, zoom: 15.0, bearing: 0);
          if (_controller != null) {
            _controller!.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
          }
          states = widget.addressModel!.state!;
          country = widget.addressModel!.country!;
          pincode = widget.addressModel!.pincode!;
          latitude = widget.addressModel!.latitude!.toString();
          longitude = widget.addressModel!.longitude!.toString();
          area = widget.addressModel!.area!;
          areaRoadApartmentNameController.text = widget.addressModel!.area!;
          areaRoadApartmentNameController.selection = TextSelection.fromPosition(TextPosition(offset: areaRoadApartmentNameController.text.length));
          address = widget.addressModel!.address!;
          city = widget.addressModel!.city!;

          locationController.text = widget.addressModel!.address! +
              "," +
              widget.addressModel!.area! +
              "," +
              widget.addressModel!.city.toString() +
              "," +
              widget.addressModel!.state! +
              "," +
              widget.addressModel!.pincode!;
          _markers.add(Marker(
            markerId: const MarkerId("Marker"),
            position: LatLng(double.parse(widget.addressModel!.latitude!), double.parse(widget.addressModel!.longitude!)),
          ));
        });
      }
    }
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
    _cameraPosition = const CameraPosition(target: LatLng(0, 0), zoom: 10.0);
    getUserLocation();
    locationStatus = widget.addressModel!.type!; //locationStatus
    alternateMobileNumberController = TextEditingController(text: widget.addressModel!.address!);
    areaRoadApartmentNameController = TextEditingController(text: widget.addressModel!.area!);
    addressController = TextEditingController(text: widget.addressModel!.address!);
    cityController = TextEditingController(text: widget.addressModel!.city!);
    landmarkController = TextEditingController(text: widget.addressModel!.landmark!);
  }

  @override
  void dispose() {
    areaRoadApartmentNameController.dispose();
    addressController.dispose();
    cityController.dispose();
    alternateMobileNumberController.dispose();
    landmarkController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Widget cityField() {
    return Container(
        padding: EdgeInsets.only(left: width! / 20.0),
        child: TextField(
          controller: cityController,
          cursorColor: ColorsRes.lightFont,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: StringsRes.enterCity,
            labelStyle: const TextStyle(
              color: ColorsRes.lightFont,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: const TextStyle(
              color: ColorsRes.lightFont,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            contentPadding: EdgeInsets.zero,
          ),
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: ColorsRes.lightFont,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  Widget addressField() {
    return Container(
        padding: EdgeInsets.only(left: width! / 20.0),
        child: TextField(
          controller: addressController,
          cursorColor: ColorsRes.lightFont,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: StringsRes.enterAddress,
            labelStyle: const TextStyle(
              color: ColorsRes.lightFont,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: const TextStyle(
              color: ColorsRes.lightFont,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            contentPadding: EdgeInsets.zero,
          ),
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: ColorsRes.lightFont,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  Widget areaRoadApartmentNameField() {
    return Container(
        padding: EdgeInsets.only(left: width! / 20.0),
        child: TextField(
          controller: areaRoadApartmentNameController,
          cursorColor: ColorsRes.lightFont,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: StringsRes.enterAreaRoadApartmentName,
            labelStyle: const TextStyle(
              color: ColorsRes.lightFont,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: const TextStyle(
              color: ColorsRes.lightFont,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            contentPadding: EdgeInsets.zero,
          ),
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: ColorsRes.lightFont,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  Widget alternateMobileNumberField() {
    return Container(
        padding: EdgeInsets.only(left: width! / 20.0),
        child: TextField(
          controller: alternateMobileNumberController,
          cursorColor: ColorsRes.lightFont,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: StringsRes.enterAlternateMobileNumber,
            labelStyle: const TextStyle(
              color: ColorsRes.lightFont,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: const TextStyle(
              color: ColorsRes.lightFont,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            contentPadding: EdgeInsets.zero,
          ),
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: ColorsRes.lightFont,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  Widget landmarkField() {
    return Container(
        padding: EdgeInsets.only(left: width! / 20.0),
        child: TextField(
          controller: landmarkController,
          cursorColor: ColorsRes.lightFont,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: StringsRes.enterLandmark,
            labelStyle: const TextStyle(
              color: ColorsRes.lightFont,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: const TextStyle(
              color: ColorsRes.lightFont,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            contentPadding: EdgeInsets.zero,
          ),
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: ColorsRes.lightFont,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  Widget tagLocation() {
    return Row(children: [
      TextButton(
          style: TextButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
          ),
          onPressed: () {
            setState(() {
              locationStatus = StringsRes.home;
            });
          },
          child: Container(
              margin: EdgeInsets.only(left: width! / 15.0, right: width! / 99.0, top: height! / 99.0),
              width: width! / 5.0,
              padding: EdgeInsets.only(
                top: height! / 99.0,
                bottom: height! / 99.0,
              ),
              decoration: locationStatus == StringsRes.home
                  ? DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 5.0)
                  : DesignConfig.boxDecorationContainerBorder(ColorsRes.lightFont, ColorsRes.white, 5.0),
              child: Text(StringsRes.home,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                      color: locationStatus == StringsRes.home ? ColorsRes.white : ColorsRes.lightFont, fontSize: 14, fontWeight: FontWeight.w500)))),
      TextButton(
          style: TextButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
          ),
          onPressed: () {
            setState(() {
              locationStatus = StringsRes.office;
            });
          },
          child: Container(
              margin: EdgeInsets.only(right: width! / 99.0, top: height! / 99.0),
              width: width! / 5.0,
              padding: EdgeInsets.only(top: height! / 99.0, bottom: height! / 99.0),
              decoration: locationStatus == StringsRes.office
                  ? DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 5.0)
                  : DesignConfig.boxDecorationContainerBorder(ColorsRes.lightFont, ColorsRes.white, 5.0),
              child: Text(StringsRes.work,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                      color: locationStatus == StringsRes.office ? ColorsRes.white : ColorsRes.lightFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)))),
      TextButton(
          style: TextButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
          ),
          onPressed: () {
            setState(() {
              locationStatus = StringsRes.other;
            });
          },
          child: Container(
              margin: EdgeInsets.only(right: width! / 40.0, top: height! / 99.0),
              width: width! / 5.0,
              padding: EdgeInsets.only(top: height! / 99.0, bottom: height! / 99.0),
              decoration: locationStatus == StringsRes.other
                  ? DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 5.0)
                  : DesignConfig.boxDecorationContainerBorder(ColorsRes.lightFont, ColorsRes.white, 5.0),
              child: Text(StringsRes.other,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                      color: locationStatus == StringsRes.other ? ColorsRes.white : ColorsRes.lightFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)))),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return _connectionStatus == 'ConnectivityResult.none'
        ? const NoInternetScreen()
        : Scaffold(
            body: Stack(
            children: [
              SizedBox(
                height: height! / 1.8,
                child: (latlong != null)
                    ? GoogleMap(
                        initialCameraPosition: _cameraPosition,
                        onMapCreated: (GoogleMapController controller) {
                          _controller = (controller);
                          _controller!.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
                        },
                        markers: this.myMarker(),
                        onTap: (latLng) {
                          if (mounted) {
                            setState(() {
                              latlong = latLng;
                            });
                            getLocation();
                          }
                        })
                    : Container(),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(top: height! / 2.5),
                  decoration: DesignConfig.boxCurveShadow(),
                  width: width,
                  child: Container(
                    margin: EdgeInsets.only(top: height! / 30.0),
                    child: SingleChildScrollView(
                      child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(
                          padding: EdgeInsets.only(left: width! / 20.0),
                          child: TextField(
                            style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14),
                            cursorColor: ColorsRes.backgroundDark,
                            controller: locationController,
                            readOnly: true,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: StringsRes.pickup,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width! / 20.0, top: height! / 60.0),
                          child: Text(StringsRes.completeAddress,
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                        ),
                        addressField(),
                        Padding(
                          padding: EdgeInsets.only(bottom: height! / 40.0, top: height! / 60.0),
                          child: Divider(
                            color: ColorsRes.lightFont,
                            height: 1.0,
                            endIndent: width! / 20.0,
                            indent: width! / 20.0,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width! / 20.0),
                          child: Text(StringsRes.areaRoadApartmentName,
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                        ),
                        areaRoadApartmentNameField(),
                        Padding(
                          padding: EdgeInsets.only(bottom: height! / 40.0),
                          child: Divider(
                            color: ColorsRes.lightFont,
                            height: 1.0,
                            endIndent: width! / 20.0,
                            indent: width! / 20.0,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width! / 20.0, top: height! / 60.0),
                          child: Text(StringsRes.alternateMobileNumber,
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                        ),
                        alternateMobileNumberField(),
                        Padding(
                          padding: EdgeInsets.only(bottom: height! / 40.0),
                          child: Divider(
                            color: ColorsRes.lightFont,
                            height: 1.0,
                            endIndent: width! / 20.0,
                            indent: width! / 20.0,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width! / 20.0, top: height! / 60.0),
                          child: Text(StringsRes.landmark,
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                        ),
                        landmarkField(),
                        city == ""
                            ? Padding(
                                padding: EdgeInsets.only(left: width! / 20.0, top: height! / 60.0),
                                child: Text(StringsRes.city,
                                    textAlign: TextAlign.start,
                                    maxLines: 2,
                                    style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                              )
                            : Container(),
                        city == "" ? cityField() : Container(),
                        Padding(
                          padding: EdgeInsets.only(bottom: height! / 40.0),
                          child: Divider(
                            color: ColorsRes.lightFont,
                            height: 1.0,
                            endIndent: width! / 20.0,
                            indent: width! / 20.0,
                          ),
                        ),
                        // additionalInstructions(),
                        Padding(
                          padding: EdgeInsets.only(left: width! / 20.0),
                          child: Text(StringsRes.tagThisLocationForLater,
                              style: const TextStyle(fontSize: 14.0, color: ColorsRes.lightFont, fontWeight: FontWeight.w500)),
                        ),
                        tagLocation(),
                        BlocConsumer<UpdateAddressCubit, UpdateAddressState>(
                            bloc: context.read<UpdateAddressCubit>(),
                            listener: (context, state) {
                              if (state is UpdateAddressSuccess) {
                                context.read<AddressCubit>().editAddress(state.addressModel);
                                Navigator.pop(context);
                              }
                            },
                            builder: (context, state) {
                              return TextButton(
                                  style: TextButton.styleFrom(
                                    splashFactory: NoSplash.splashFactory,
                                  ),
                                  onPressed: () {
                                    context.read<UpdateAddressCubit>().fetchUpdateAddress(
                                          widget.addressModel!.id!,
                                          context.read<AuthCubit>().getId(),
                                          context.read<AuthCubit>().getMobile(),
                                          addressController.text,
                                          city == "" ? cityController.text : city,
                                          latitude ?? "",
                                          longitude ?? "",
                                          areaRoadApartmentNameController.text,
                                          locationStatus,
                                          context.read<AuthCubit>().getName(),
                                          context.read<AuthCubit>().getCountryCode(),
                                          alternateMobileNumberController.text,
                                          landmarkController.text,
                                          pincode ?? "",
                                          states ?? "",
                                          country ?? "",
                                          "0",
                                        );
                                  },
                                  child: Container(
                                      margin: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0, bottom: height! / 55.0),
                                      width: width,
                                      padding:
                                          EdgeInsets.only(top: height! / 55.0, bottom: height! / 55.0, left: width! / 20.0, right: width! / 20.0),
                                      decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 10.0),
                                      child: Text(state is UpdateAddressProgress ? StringsRes.updateIngLocation : StringsRes.updateLocation,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500))));
                            }),
                      ]),
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
          ));
  }

  Set<Marker> myMarker() {
    if (_markers != null) {
      _markers.clear();
    }

    _markers.add(Marker(
      markerId: MarkerId(Random().nextInt(10000).toString()),
      position: LatLng(latlong!.latitude, latlong!.longitude),
    ));

    return _markers;
  }

  Future<void> getLocation() async {
    List<Placemark> placemark = await placemarkFromCoordinates(latlong!.latitude, latlong!.longitude);

    var address1;

    address1 = placemark[0].name;

    address1 = address1 + "," + placemark[0].subLocality;
    address1 = address1 + "," + placemark[0].locality;
    address1 = address1 + "," + placemark[0].administrativeArea;
    address1 = address1 + "," + placemark[0].country;
    address1 = address1 + "," + placemark[0].postalCode;

    states = placemark[0].administrativeArea;
    country = placemark[0].country;
    pincode = placemark[0].postalCode;
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();
    area = placemark[0].subLocality;
    areaRoadApartmentNameController.text = placemark[0].subLocality!;
    areaRoadApartmentNameController.selection = TextSelection.fromPosition(TextPosition(offset: areaRoadApartmentNameController.text.length));
    address = placemark[0].name;
    addressController = TextEditingController(
        text: placemark[0].name! + "," + placemark[0].subLocality! + "," + placemark[0].locality! + "," + placemark[0].administrativeArea!);
    city = placemark[0].locality;

    locationController.text = address1;
    if (mounted) setState(() {});
  }
}
