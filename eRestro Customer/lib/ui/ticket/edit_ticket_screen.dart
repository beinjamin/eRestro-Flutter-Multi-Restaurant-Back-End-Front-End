import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/helpAndSupport/cubit/helpAndSupportCubit.dart';
import 'package:erestro/features/helpAndSupport/cubit/editTicketCubit.dart';
import 'package:erestro/features/helpAndSupport/cubit/ticketCubit.dart';
import 'package:erestro/features/helpAndSupport/helpAndSupportRepository.dart';
import 'package:erestro/model/ticketStatusType.dart';
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

class EditTicketScreen extends StatefulWidget {
  final int? id, typeId;
  final String? email, subject, message, status;
  const EditTicketScreen({Key? key, this.id, this.typeId, this.email, this.subject, this.message, this.status}) : super(key: key);

  @override
  EditTicketScreenState createState() => EditTicketScreenState();
  static Route<EditTicketScreen> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<HelpAndSupportCubit>(create: (_) => HelpAndSupportCubit(HelpAndSupportRepository())),
                BlocProvider<EditTicketCubit>(create: (_) => EditTicketCubit(HelpAndSupportRepository())),
              ],
              child: EditTicketScreen(
                  id: arguments['id'] as int,
                  typeId: arguments['typeId'] as int,
                  email: arguments['email'] as String,
                  subject: arguments['subject'],
                  message: arguments['message'] as String,
                  status: arguments['status'] as String),
            ));
  }
}

class EditTicketScreenState extends State<EditTicketScreen> {
  double? width, height;
  bool enableList = false, enableTicketStatusTypeList = false;
  int? _selectedIndex, _selectedTicketStatusTypeIndex;
  late TextEditingController emailController;
  late TextEditingController subjectController;
  late TextEditingController messageController;
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
    emailController = TextEditingController(text: widget.email);
    subjectController = TextEditingController(text: widget.subject);
    messageController = TextEditingController(text: widget.message);
    _selectedIndex = widget.typeId;
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

  onChangedTicketTypeStatus(int position) {
    setState(() {
      _selectedTicketStatusTypeIndex = position;
      enableTicketStatusTypeList = !enableTicketStatusTypeList;
    });
  }

  onTapTicketTypeStatus() {
    setState(() {
      enableTicketStatusTypeList = !enableTicketStatusTypeList;
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
          _selectedIndex = helpAndSupportList.indexWhere((element) => element.id == widget.typeId.toString());
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

  Widget selectTicketStatusTypeType() {
    _selectedTicketStatusTypeIndex = ticketStatusList.indexWhere((element) => element.id == widget.status.toString());
    return Container(
      decoration: DesignConfig.boxDecorationContainerCardShadow(ColorsRes.white, ColorsRes.shadow, 10.0, 0.0, 0.0, 10.0, 0.0),
      margin: EdgeInsets.only(top: height! / 99.0),
      child: Column(
        children: [
          InkWell(
            onTap: onTapTicketTypeStatus,
            child: Container(
              decoration: DesignConfig.boxDecorationContainer(ColorsRes.textFieldBackground, 10.0),
              padding: EdgeInsets.only(left: width! / 40.0, right: width! / 99.0, top: height! / 99.0, bottom: height! / 99.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                      child: Text(
                    _selectedTicketStatusTypeIndex != null ? ticketStatusList[_selectedTicketStatusTypeIndex!].title! : StringsRes.selectType,
                    style: const TextStyle(fontSize: 12.0, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500),
                  )),
                  Icon(enableTicketStatusTypeList ? Icons.expand_less : Icons.expand_more, size: 24.0, color: ColorsRes.backgroundDark),
                ],
              ),
            ),
          ),
          enableTicketStatusTypeList
              ? ListView.builder(
                  padding: EdgeInsets.only(top: height! / 99.9, bottom: height! / 99.0),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  itemCount: ticketStatusList.length,
                  itemBuilder: (context, position) {
                    return InkWell(
                      onTap: () {
                        onChangedTicketTypeStatus(position);
                        //ticketTypeId = helpAndSupportList[position].id!;
                      },
                      child: Container(
                          padding: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0, top: height! / 99.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticketStatusList[position].title!,
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
  }

  Widget selectTypeDropdown() {
    return InkWell(
      onTap: onTapTicketTypeStatus,
      child: Container(
        decoration: DesignConfig.boxDecorationContainer(ColorsRes.textFieldBackground, 10.0),
        padding: EdgeInsets.only(left: width! / 40.0, right: width! / 99.0, top: height! / 99.0, bottom: height! / 99.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
                child: Text(
              _selectedTicketStatusTypeIndex != null ? ticketStatusList[_selectedTicketStatusTypeIndex!].title! : StringsRes.selectType,
              style: const TextStyle(fontSize: 12.0, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500),
            )),
            Icon(enableList ? Icons.expand_less : Icons.expand_more, size: 24.0, color: ColorsRes.backgroundDark),
          ],
        ),
      ),
    );
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
              bottomNavigationBar: BlocConsumer<EditTicketCubit, EditTicketState>(
                bloc: context.read<EditTicketCubit>(),
                listener: (context, state) {
                  if (state is EditTicketSuccess) {
                    context.read<TicketCubit>().addTicket(state.ticketModel);
                    // Navigator.pop(context);
                    UiUtils.setSnackBar(StringsRes.ticketUpdate, StringsRes.ticketUpdateSuccessfully, context, false);
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
                          context.read<EditTicketCubit>().fetchEditTicket(widget.id.toString(), widget.typeId.toString(), subjectController.text,
                              emailController.text, messageController.text, context.read<AuthCubit>().getId(), widget.status);
                          emailController.clear();
                          subjectController.clear();
                          messageController.clear();
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
                },
              ),
              body: Container(
                margin: EdgeInsets.only(top: height! / 30.0),
                decoration: DesignConfig.boxCurveShadow(),
                width: width,
                child: Container(
                  margin: EdgeInsets.only(left: width! / 20.0, right: width! / 20.0, top: height! / 60.0),
                  child: SingleChildScrollView(
                    child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(StringsRes.selectYourQuestion,
                          style: const TextStyle(fontSize: 14.0, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500)),
                      Padding(
                        padding: EdgeInsets.only(top: height! / 99.0, bottom: height! / 70.0),
                        child: Divider(
                          color: ColorsRes.lightFont.withOpacity(0.50),
                          height: 1.0,
                        ),
                      ),
                      selectType(),
                      Padding(
                        padding: EdgeInsets.only(top: height! / 99.0, bottom: height! / 70.0),
                        child: Divider(
                          color: ColorsRes.lightFont.withOpacity(0.50),
                          height: 1.0,
                        ),
                      ),
                      selectTicketStatusTypeType(),
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
