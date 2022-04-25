import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/app/routes.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/helpAndSupport/cubit/addTicketCubit.dart';
import 'package:erestro/features/helpAndSupport/cubit/helpAndSupportCubit.dart';
import 'package:erestro/features/helpAndSupport/cubit/ticketCubit.dart';
import 'package:erestro/features/helpAndSupport/helpAndSupportRepository.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../utils/internetConnectivity.dart';

class AddTicketScreen extends StatefulWidget {
  const AddTicketScreen({Key? key}) : super(key: key);

  @override
  AddTicketScreenState createState() => AddTicketScreenState();
  static Route<AddTicketScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<HelpAndSupportCubit>(create: (_) => HelpAndSupportCubit(HelpAndSupportRepository())),
                BlocProvider<AddTicketCubit>(create: (_) => AddTicketCubit(HelpAndSupportRepository())),
                BlocProvider<TicketCubit>(create: (_) => TicketCubit()),
              ],
              child: const AddTicketScreen(),
            ));
  }
}

class AddTicketScreenState extends State<AddTicketScreen> {
  double? width, height;
  bool enableList = false;
  int? _selectedIndex;
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController subjectController = TextEditingController(text: "");
  TextEditingController messageController = TextEditingController(text: "");
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String? ticketTypeId;

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
    context.read<HelpAndSupportCubit>().fetchHelpAndSupport();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  onChanged(int position) {
    setState(() {
      _selectedIndex = position;
      enableList = !enableList;
    });
  }

  onTap() {
    setState(() {
      enableList = !enableList;
    });
  }

  Widget selectType() {
    return BlocConsumer<HelpAndSupportCubit, HelpAndSupportState>(
        bloc: context.read<HelpAndSupportCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is HelpAndSupportProgress || state is HelpAndSupportInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HelpAndSupportFailure) {
            return const Center(child: Text(""));
          }
          final helpAndSupportList = (state as HelpAndSupportSuccess).helpAndSupportList;
          return Container(
            decoration: DesignConfig.boxDecorationContainerCardShadow(ColorsRes.white, ColorsRes.shadow, 10.0, 0.0, 0.0, 10.0, 0.0),
            margin: EdgeInsets.only(top: height! / 99.0),
            child: Column(
              children: [
                InkWell(
                  onTap: onTap,
                  child: Container(
                    decoration: DesignConfig.boxDecorationContainer(ColorsRes.textFieldBackground, 10.0),
                    padding: EdgeInsets.only(left: width! / 40.0, right: width! / 99.0, top: height! / 99.0, bottom: height! / 99.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                            child: Text(
                          _selectedIndex != null ? helpAndSupportList[_selectedIndex!].title! : StringsRes.selectType,
                          style: const TextStyle(fontSize: 12.0, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500),
                        )),
                        Icon(enableList ? Icons.expand_less : Icons.expand_more, size: 24.0, color: ColorsRes.backgroundDark),
                      ],
                    ),
                  ),
                ),
                enableList
                    ? ListView.builder(
                        padding: EdgeInsets.only(top: height! / 99.9, bottom: height! / 99.0),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        itemCount: helpAndSupportList.length,
                        itemBuilder: (context, position) {
                          return InkWell(
                            onTap: () {
                              onChanged(position);
                              ticketTypeId = helpAndSupportList[position].id!;
                            },
                            child: Container(
                                padding: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0, top: height! / 99.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      helpAndSupportList[position].title!,
                                      style: const TextStyle(fontSize: 12.0, color: ColorsRes.backgroundDark),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: height! / 99.0),
                                      child: Divider(
                                        color: ColorsRes.lightFont.withOpacity(0.10),
                                        height: 1.0,
                                      ),
                                    ),
                                  ],
                                )),
                          );
                        })
                    : Container(),
              ],
            ),
          );
        });
  }

  Widget email() {
    return Container(
      padding: EdgeInsets.only(left: width! / 40.0, right: width! / 99.0),
      decoration: DesignConfig.boxDecorationContainer(ColorsRes.textFieldBackground, 10.0),
      margin: EdgeInsets.only(top: height! / 60.0),
      child: TextField(
        controller: emailController,
        cursorColor: ColorsRes.backgroundDark,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: StringsRes.email,
          labelStyle: const TextStyle(
            color: ColorsRes.backgroundDark,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: const TextStyle(
            color: ColorsRes.backgroundDark,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
          color: ColorsRes.backgroundDark,
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget subject() {
    return Container(
      padding: EdgeInsets.only(left: width! / 40.0, right: width! / 99.0),
      decoration: DesignConfig.boxDecorationContainer(ColorsRes.textFieldBackground, 10.0),
      margin: EdgeInsets.only(top: height! / 60.0),
      child: TextField(
        controller: subjectController,
        cursorColor: ColorsRes.backgroundDark,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: StringsRes.subject,
          labelStyle: const TextStyle(
            color: ColorsRes.backgroundDark,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: const TextStyle(
            color: ColorsRes.backgroundDark,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        keyboardType: TextInputType.text,
        style: const TextStyle(
          color: ColorsRes.backgroundDark,
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget message() {
    return Container(
      padding: EdgeInsets.only(left: width! / 40.0, right: width! / 99.0),
      decoration: DesignConfig.boxDecorationContainer(ColorsRes.textFieldBackground, 10.0),
      margin: EdgeInsets.only(top: height! / 60.0),
      child: TextField(
        controller: messageController,
        cursorColor: ColorsRes.backgroundDark,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: StringsRes.message,
          labelStyle: const TextStyle(
            color: ColorsRes.backgroundDark,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: const TextStyle(
            color: ColorsRes.backgroundDark,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        keyboardType: TextInputType.text,
        style: const TextStyle(
          color: ColorsRes.backgroundDark,
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 5,
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
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
                title: Text(StringsRes.helpAndSupport,
                    textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              bottomNavigationBar: BlocConsumer<AddTicketCubit, AddTicketState>(
                  bloc: context.read<AddTicketCubit>(),
                  listener: (context, state) {
                    if (state is AddTicketSuccess) {
                      //print("Successfull..!!");
                      context.read<TicketCubit>().addTicket(state.ticketModel);
                      // Navigator.pop(context);
                      UiUtils.setSnackBar(StringsRes.ticketAdd, StringsRes.ticketAddSuccessfully, context, false);
                      emailController.clear();
                      subjectController.clear();
                      messageController.clear();
                    }
                  },
                  builder: (context, state) {
                    return TextButton(
                        style: TextButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                        ),
                        onPressed: () {
                          if (emailController.text.isEmpty) {
                            UiUtils.setSnackBar(StringsRes.email, StringsRes.enterEmail, context, false);
                          } else if (subjectController.text.isEmpty) {
                            UiUtils.setSnackBar(StringsRes.subject, StringsRes.enterSubject, context, false);
                          } else if (messageController.text.isEmpty) {
                            UiUtils.setSnackBar(StringsRes.message, StringsRes.enterMessage, context, false);
                          } else if (_selectedIndex.toString().isEmpty) {
                            UiUtils.setSnackBar(StringsRes.selectType, StringsRes.resendSnackBar, context, false);
                          } else {
                            print(_selectedIndex);
                            context.read<AddTicketCubit>().fetchAddTicket(ticketTypeId.toString(), subjectController.text, emailController.text,
                                messageController.text, context.read<AuthCubit>().getId());
                          }
                        },
                        child: Container(
                            margin: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0, bottom: height! / 55.0),
                            width: width,
                            padding: EdgeInsets.only(top: height! / 55.0, bottom: height! / 55.0, left: width! / 20.0, right: width! / 20.0),
                            decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 100.0),
                            child: Text(StringsRes.sendMessage,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500))));
                  }),
              body: Container(
                margin: EdgeInsets.only(top: height! / 30.0),
                decoration: DesignConfig.boxCurveShadow(),
                width: width,
                child: Container(
                  margin: EdgeInsets.only(left: width! / 20.0, right: width! / 20.0, top: height! / 60.0),
                  child: SingleChildScrollView(
                    child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(
                        children: [
                          Text(StringsRes.selectYourQuestion,
                              style: const TextStyle(fontSize: 14.0, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500)),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed(Routes.ticket);
                            },
                            child: Text(StringsRes.view,
                                style: const TextStyle(fontSize: 12.0, color: ColorsRes.lightFont, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: height! / 99.0, bottom: height! / 70.0),
                        child: Divider(
                          color: ColorsRes.lightFont.withOpacity(0.50),
                          height: 1.0,
                        ),
                      ),
                      selectType(),
                      email(),
                      subject(),
                      message(),
                    ]),
                  ),
                ),
              )),
    );
  }
}
