import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:erestro/features/profileManagement/cubits/uploadProfileCubit.dart';
import 'package:erestro/features/profileManagement/profileManagementRepository.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/internetConnectivity.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (context) => MultiBlocProvider(providers: [
        BlocProvider<UploadProfileCubit>(
            create: (context) => UploadProfileCubit(
                  ProfileManagementRepository(),
                )),
        BlocProvider<UpdateUserDetailCubit>(create: (_) => UpdateUserDetailCubit(ProfileManagementRepository())),
      ], child: const ProfileScreen()),
    );
  }
}

class ProfileScreenState extends State<ProfileScreen> {
  double? width, height;
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController phoneNumberController = TextEditingController(text: "");
  TextEditingController referralCodeController = TextEditingController(text: "");
  //TextEditingController addressController = TextEditingController(text: "");
  String? countryCode = "+91";
  bool _isNetworkAvail = true;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  File? image;
  // get image File camera
  _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    File rotatedImage = await FlutterExifRotation.rotateAndSaveImage(path: pickedFile!.path);
    if (pickedFile != null) {
      image = rotatedImage;
      final userId = context.read<AuthCubit>().getId();
      context.read<UploadProfileCubit>().uploadProfilePicture(image, userId);
    }
  }

//get image file from library
  _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    File rotatedImage = await FlutterExifRotation.rotateAndSaveImage(path: pickedFile!.path);
    if (pickedFile != null) {
      image = rotatedImage;
      //File(pickedFile.path);
      final userId = context.read<AuthCubit>().getId();

      context.read<UploadProfileCubit>().uploadProfilePicture(image, userId);
    }
  }

  Future chooseProfile(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: DesignConfig.setRounded(25.0),
            //title: Text('Not in stock'),
            content: SizedBox(
              height: height! / 5.5,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                TextButton.icon(
                    icon: const Icon(
                      Icons.photo_library,
                      color: ColorsRes.backgroundDark,
                    ),
                    label: Text(
                      StringsRes.gallery,
                      style: const TextStyle(color: ColorsRes.backgroundDark, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      _getFromGallery();
                      Navigator.of(context).pop();
                    }),
                TextButton.icon(
                  icon: const Icon(
                    Icons.photo_camera,
                    color: ColorsRes.backgroundDark,
                  ),
                  label: Text(
                    StringsRes.camera,
                    style: const TextStyle(color: ColorsRes.backgroundDark, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    _getFromCamera();
                    Navigator.of(context).pop();
                  },
                )
              ]),
            ));
      },
    );
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
    nameController = TextEditingController(text: context.read<AuthCubit>().getName());
    emailController = TextEditingController(text: context.read<AuthCubit>().getEmail());
    phoneNumberController = TextEditingController(text: context.read<AuthCubit>().getMobile());
    referralCodeController = TextEditingController(text: context.read<AuthCubit>().getReferralCode());
    //addressController = TextEditingController(text: context.read<AuthCubit>().getAddress());
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    referralCodeController.dispose();
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
                        child: SvgPicture.asset(DesignConfig.setSvgPath("cancel_icon"), width: 32, height: 32))),
                backgroundColor: ColorsRes.white,
                shadowColor: ColorsRes.white,
                elevation: 0,
                centerTitle: true,
                title: Text(StringsRes.profile,
                    textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              bottomNavigationBar: BlocConsumer<UpdateUserDetailCubit, UpdateUserDetailState>(
                  bloc: context.read<UpdateUserDetailCubit>(),
                  listener: (context, state) {
                    if (state is UpdateUserDetailSuccess) {
                      context.read<AuthCubit>().updateUserName(state.authModel.username ?? "");
                      context.read<AuthCubit>().updateUserEmail(state.authModel.email ?? "");
                      context.read<AuthCubit>().updateUserReferralCode(state.authModel.referralCode ?? "");
                      UiUtils.setSnackBar(StringsRes.profile, StringsRes.updateSuccessFully, context, false);
                      // Navigator.pop(context);
                    } else if (state is UpdateUserDetailFailure) {
                      UiUtils.setSnackBar(StringsRes.profile, state.errorMessage, context, false);
                    }
                  },
                  builder: (context, state) {
                    return TextButton(
                        style: TextButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                        ),
                        onPressed: () {
                          context.read<UpdateUserDetailCubit>().updateProfile(
                              userId: context.read<AuthCubit>().getId(),
                              name: nameController.text,
                              email: emailController.text,
                              mobile: phoneNumberController.text,
                              referralCode: referralCodeController.text);
                        },
                        child: Container(
                            margin: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0, bottom: height! / 55.0),
                            width: width,
                            padding: EdgeInsets.only(top: height! / 55.0, bottom: height! / 55.0, left: width! / 20.0, right: width! / 20.0),
                            decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 100.0),
                            child: Text(StringsRes.saveProfile,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500))));
                  }),
              body: BlocConsumer<UploadProfileCubit, UploadProfileState>(listener: (context, state) {
                if (state is UploadProfileFailure) {
                  UiUtils.setSnackBar(StringsRes.profile, state.errorMessage, context, false);
                } else if (state is UploadProfileSuccess) {
                  context.read<AuthCubit>().updateUserProfileUrl(state.imageUrl);
                }
              }, builder: (context, state) {
                return Container(
                    margin: EdgeInsets.only(top: height! / 30.0),
                    decoration: DesignConfig.boxCurveShadow(),
                    width: width,
                    child: Container(
                      margin: EdgeInsets.only(left: width! / 20.0, right: width! / 20.0, top: height! / 20.0),
                      child: SingleChildScrollView(
                        child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Padding(
                            padding: EdgeInsets.only(left: width! / 10.0, right: width! / 10.0, bottom: height! / 25.0),
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Center(
                                  child: CircleAvatar(
                                    radius: 45,
                                    backgroundColor: ColorsRes.white.withOpacity(0.50),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: ClipOval(
                                          child: FadeInImage(
                                        placeholder: AssetImage(
                                          DesignConfig.setPngPath('placeholder_square'),
                                        ),
                                        image: NetworkImage(
                                          context.read<AuthCubit>().getProfile(),
                                        ),
                                        imageErrorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            DesignConfig.setPngPath('placeholder_square'),
                                          );
                                        },
                                        width: 85,
                                        height: 85,
                                        fit: BoxFit.cover,
                                      )),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: height! / 15.0, left: width! / 5.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      chooseProfile(context);
                                    },
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: ColorsRes.white,
                                      child: CircleAvatar(
                                        radius: 18,
                                        backgroundColor: ColorsRes.red,
                                        child: Container(
                                            alignment: Alignment.center,
                                            child: SvgPicture.asset(
                                              DesignConfig.setSvgPath("change_acc_pic_icon"),
                                              width: 20,
                                              height: 20,
                                            )),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(StringsRes.fullName,
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                          Container(
                              /*decoration: DesignConfig.boxDecorationContainer(ColorsRes.white, 10.0), height: height/16.0,*/
                              padding: EdgeInsets.zero,
                              margin: EdgeInsets.zero,
                              child: TextField(
                                controller: nameController,
                                cursorColor: ColorsRes.lightFont,
                                decoration: InputDecoration(
                                  /*labelText: 'Mobile Number',*/
                                  border: InputBorder.none,
                                  /*border: OutlineInputBorder(
                                borderSide: BorderSide(),
                              ),*/
                                  hintText: StringsRes.fullName,
                                  labelStyle: const TextStyle(
                                    color: ColorsRes.lightFont,
                                    fontSize: 14.0,
                                  ),
                                  hintStyle: const TextStyle(
                                    color: ColorsRes.lightFont,
                                    fontSize: 14.0,
                                  ),
                                  contentPadding: const EdgeInsets.only(top: 10.0),
                                ),
                                keyboardType: TextInputType.text,
                                style: const TextStyle(
                                  color: ColorsRes.lightFont,
                                  fontSize: 14.0,
                                ),
                              )),
                          Padding(
                            padding: EdgeInsets.only(bottom: height! / 30.0),
                            child: const Divider(
                              color: ColorsRes.textFieldBorder,
                              height: 0.0,
                            ),
                          ),
                          Text(StringsRes.emailId,
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                          Container(
                              /*decoration: DesignConfig.boxDecorationContainer(ColorsRes.white, 10.0), height: height/16.0,*/
                              padding: EdgeInsets.zero,
                              margin: EdgeInsets.zero,
                              child: TextField(
                                controller: emailController,
                                cursorColor: ColorsRes.lightFont,
                                decoration: InputDecoration(
                                  /*labelText: 'Mobile Number',*/
                                  border: InputBorder.none,
                                  /*border: OutlineInputBorder(
                                borderSide: BorderSide(),
                              ),*/
                                  hintText: StringsRes.enterEmail,
                                  labelStyle: const TextStyle(
                                    color: ColorsRes.lightFont,
                                    fontSize: 14.0,
                                  ),
                                  hintStyle: const TextStyle(
                                    color: ColorsRes.lightFont,
                                    fontSize: 14.0,
                                  ),
                                  contentPadding: EdgeInsets.only(top: height! / 40.0),
                                ),
                                keyboardType: TextInputType.text,
                                style: const TextStyle(
                                  color: ColorsRes.lightFont,
                                  fontSize: 14.0,
                                ),
                              )),
                          Padding(
                            padding: EdgeInsets.only(bottom: height! / 30.0),
                            child: const Divider(
                              color: ColorsRes.textFieldBorder,
                              height: 0.0,
                            ),
                          ),
                          Text(StringsRes.phoneNumber,
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                          Container(
                              /*decoration: DesignConfig.boxDecorationContainer(ColorsRes.white, 10.0), height: height/16.0,*/
                              padding: EdgeInsets.zero,
                              margin: EdgeInsets.zero,
                              child: TextField(
                                  controller: phoneNumberController,
                                  enabled: false,
                                  decoration: InputDecoration(
                                    counterStyle: const TextStyle(color: ColorsRes.white, fontSize: 0),
                                    border: InputBorder.none,
                                    hintText: StringsRes.enterPhoneNumber,
                                    labelStyle: const TextStyle(
                                      color: ColorsRes.lightFont,
                                      fontSize: 14.0,
                                    ),
                                    hintStyle: const TextStyle(
                                      color: ColorsRes.lightFont,
                                      fontSize: 14.0,
                                    ),
                                    contentPadding: EdgeInsets.only(top: height! / 40.0),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    color: ColorsRes.lightFont,
                                    fontSize: 14,
                                  ))),
                          const Divider(
                            color: ColorsRes.textFieldBorder,
                            height: 0.0,
                          ),
                          /*Padding(
                          padding: EdgeInsets.only(bottom: height !/ 30.0),
                          child: const Divider(color: ColorsRes.textFieldBorder,
                            height: 0.0,),
                        ),
                        Text(StringsRes.address, textAlign: TextAlign.start,
                            maxLines: 2,
                            style: const TextStyle(color: ColorsRes
                                .backgroundDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        Container(decoration: DesignConfig.boxDecorationContainer(ColorsRes.white, 10.0), height: height/16.0,
                            padding: EdgeInsets.zero, margin: EdgeInsets.zero,
                            child: TextField(controller: addressController,
                                decoration: InputDecoration(
                                  counterStyle: const TextStyle(
                                      color: ColorsRes.white, fontSize: 0),
                                  border: InputBorder.none,
                                  hintText: StringsRes.enterAddress,
                                  labelStyle: const TextStyle(
                                    color: ColorsRes.lightFont,
                                    fontSize: 14.0,
                                  ),
                                  hintStyle: const TextStyle(
                                    color: ColorsRes.lightFont,
                                    fontSize: 14.0,
                                  ),
                                  contentPadding: EdgeInsets.only(
                                      top: height !/ 40.0),
                                ), keyboardType: TextInputType.text,
                              style: const TextStyle(
                                color: ColorsRes.lightFont,
                                fontSize: 14,
                              )
                            )),
                        const Divider(
                          color: ColorsRes.textFieldBorder, height: 0.0,),*/

                          Padding(
                            padding: EdgeInsets.only(bottom: height! / 30.0),
                            child: const Divider(
                              color: ColorsRes.textFieldBorder,
                              height: 0.0,
                            ),
                          ),
                          Text(StringsRes.referralCode,
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                          Container(
                              /*decoration: DesignConfig.boxDecorationContainer(ColorsRes.white, 10.0), height: height/16.0,*/
                              padding: EdgeInsets.zero,
                              margin: EdgeInsets.zero,
                              child: TextField(
                                  controller: referralCodeController,
                                  decoration: InputDecoration(
                                    counterStyle: const TextStyle(color: ColorsRes.white, fontSize: 0),
                                    border: InputBorder.none,
                                    hintText: StringsRes.enterReferralCode,
                                    labelStyle: const TextStyle(
                                      color: ColorsRes.lightFont,
                                      fontSize: 14.0,
                                    ),
                                    hintStyle: const TextStyle(
                                      color: ColorsRes.lightFont,
                                      fontSize: 14.0,
                                    ),
                                    contentPadding: EdgeInsets.only(top: height! / 40.0),
                                  ),
                                  keyboardType: TextInputType.text,
                                  style: const TextStyle(
                                    color: ColorsRes.lightFont,
                                    fontSize: 14,
                                  ))),
                          const Divider(
                            color: ColorsRes.textFieldBorder,
                            height: 0.0,
                          ),
                        ]),
                      ),
                    ));
              }),
            ),
    );
  }
}
