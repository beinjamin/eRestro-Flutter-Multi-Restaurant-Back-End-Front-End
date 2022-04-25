import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/helpAndSupport/chatModel.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';
import 'package:erestro/utils/internetConnectivity.dart';
import 'package:erestro/utils/uiUtils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ChatScreen extends StatefulWidget {
  final String? id, status;

  const ChatScreen({Key? key, this.id, this.status}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

StreamController<String>? chatScreenstreamdata;

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController msgController = new TextEditingController();
  List<File> files = [];
  List<ChatModel> chatList = [];
  late Map<String?, String> downloadlist;
  String _filePath = "";
  double? width, height;

  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  ScrollController _scrollController = new ScrollController();
  Future<List<Directory>?>? _externalStorageDirectories;

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
    _externalStorageDirectories = getExternalStorageDirectories(type: StorageDirectory.downloads);
    downloadlist = new Map<String?, String>();
    //CUR_TICK_ID = widget.id;
    FlutterDownloader.registerCallback(downloadCallback);
    setupChannel();

    getMsg();
  }

  @override
  void dispose() {
    msgController.dispose();
    //CUR_TICK_ID = '';
    if (chatScreenstreamdata != null) chatScreenstreamdata!.sink.close();

    super.dispose();
  }

  //String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
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
                title: Text(StringsRes.chat,
                    textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              body: Container(
                margin: EdgeInsets.only(top: height! / 30.0),
                decoration: DesignConfig.boxCurveShadow(),
                width: width,
                child: Container(
                  margin: EdgeInsets.only(left: width! / 20.0, right: width! / 20.0, top: height! / 60.0),
                  child: Column(
                    children: <Widget>[buildListMessage(), msgRow()],
                  ),
                ),
              ),
            ),
    );
  }

  void setupChannel() {
    chatScreenstreamdata = StreamController<String>(); //.broadcast();
    chatScreenstreamdata!.stream.listen((response) {
      setState(() {
        final res = json.decode(response);
        ChatModel message;
        String mid;

        message = ChatModel.fromJson(res["data"]);

        chatList.insert(0, message);
        files.clear();
      });
    });
  }

  void insertItem(String response) {
    if (chatScreenstreamdata != null) chatScreenstreamdata!.sink.add(response);
    _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  Widget buildListMessage() {
    return Flexible(
      child: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemBuilder: (context, index) => msgItem(index, chatList[index]),
        itemCount: chatList.length,
        reverse: true,
        controller: _scrollController,
      ),
    );
  }

  Widget msgItem(int index, ChatModel message) {
    if (message.userId == context.read<AuthCubit>().getId()) {
      //Own message
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Container(),
          ),
          Flexible(
            flex: 2,
            child: MsgContent(index, message),
          ),
        ],
      );
    } else {
      //Other's message
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            flex: 2,
            child: MsgContent(index, message),
          ),
          Flexible(
            flex: 1,
            child: Container(),
          ),
        ],
      );
    }
  }

  Widget MsgContent(int index, ChatModel message) {
    //String filetype = message.attachment_mime_type.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: message.userId == context.read<AuthCubit>().getId() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        message.userId == context.read<AuthCubit>().getId()
            ? Container()
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(message.name!, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12)),
                    )
                  ],
                ),
              ),
        ListView.builder(
            itemBuilder: (context, index) {
              return attachItem(message.attachments!, index, message);
            },
            itemCount: message.attachments!.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true),
        message.message != null && message.message!.isNotEmpty
            ? Card(
                elevation: 0.0,
                color: message.userId == context.read<AuthCubit>().getId() ? ColorsRes.backgroundDark.withOpacity(0.1) : ColorsRes.greyLightColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                  child: Column(
                    crossAxisAlignment: message.userId == context.read<AuthCubit>().getId() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("${message.message}", style: const TextStyle(color: ColorsRes.black)),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(top: 5),
                        child: Text(message.dateCreated!, style: const TextStyle(color: ColorsRes.lightFontColor, fontSize: 9)),
                      ),
                    ],
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  void _requestDownload(String? url, String? mid, AsyncSnapshot snapshot) async {
    bool checkpermission = await checkPermission(snapshot);
    if (checkpermission) {
      if (Platform.isIOS) {
        Directory target = await getApplicationDocumentsDirectory();
        _filePath = target.path.toString();
      } else {
        if (snapshot.hasData) {
          _filePath = snapshot.data!.map((Directory d) => d.path).join(', ');

          print("dir path****$_filePath");
        }
      }

      String fileName = url!.substring(url.lastIndexOf("/") + 1);
      File file = new File(_filePath + "/" + fileName);
      bool hasExisted = await file.exists();

      if (downloadlist.containsKey(mid)) {
        final tasks = await FlutterDownloader.loadTasksWithRawQuery(query: "SELECT status FROM task WHERE task_id=${downloadlist[mid]}");

        if (tasks == 4 || tasks == 5) downloadlist.remove(mid);
      }

      if (hasExisted) {
        final _openFile = await OpenFile.open(_filePath + "/" + fileName);
      } else if (downloadlist.containsKey(mid)) {
        UiUtils.setSnackBar(StringsRes.download, StringsRes.downloading, context, false);
      } else {
        UiUtils.setSnackBar(StringsRes.download, StringsRes.downloading, context, false);
        final taskid = await FlutterDownloader.enqueue(
            url: url, savedDir: _filePath, headers: {"auth": "test_for_sql_encoding"}, showNotification: true, openFileFromNotification: true);

        setState(() {
          downloadlist[mid] = taskid.toString();
        });
      }
    }
  }

  Future<bool> checkPermission(AsyncSnapshot snapshot) async {
    var status = await Permission.storage.status;

    if (status != PermissionStatus.granted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();

      if (statuses[Permission.storage] == PermissionStatus.granted) {
        fileDirectoryPrepare(snapshot);
        return true;
      }
    } else {
      fileDirectoryPrepare(snapshot);
      return true;
    }
    return false;
  }

  Future<Null> fileDirectoryPrepare(AsyncSnapshot snapshot) async {
    if (Platform.isIOS) {
      Directory target = await getApplicationDocumentsDirectory();
      _filePath = target.path.toString();
    } else {
      if (snapshot.hasData) {
        _filePath = snapshot.data!.map((Directory d) => d.path).join(', ');

        print("dir path****$_filePath");
      }
    }
  }

  _imgFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      files = result.paths.map((path) => File(path!)).toList();
      if (mounted) setState(() {});
    } else {
      // User canceled the picker
    }
  }

  Future<void> sendMessage(String message) async {
    setState(() {
      msgController.text = "";
    });
    var request = http.MultipartRequest("POST", Uri.parse(sendMessageUrl));
    request.headers.addAll(ApiUtils.getHeaders());
    request.fields[userIdKey] = context.read<AuthCubit>().getId();
    request.fields[ticketIdKey] = widget.id!;
    request.fields[userTypeKey] = userKey;
    request.fields[messageKey] = message;

    if (files != null) {
      for (int i = 0; i < files.length; i++) {
        final mimeType = lookupMimeType(files[i].path);

        var extension = mimeType!.split("/");
        var pic = await http.MultipartFile.fromPath(
          attachmentsKey,
          files[i].path,
          contentType: MediaType('image', extension[1]),
        );
        request.files.add(pic);
      }
    }

    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    var getdata = json.decode(responseString);
    bool error = getdata["error"];
    String? msg = getdata['message'];
    var data = getdata["data"];
    if (!error) {
      insertItem(responseString);
    }
  }

  Future<void> getMsg() async {
    try {
      var data = {
        ticketIdKey: widget.id,
      };

      Response response = await post(Uri.parse(getMessagesUrl), body: data, headers: ApiUtils.getHeaders()).timeout(const Duration(seconds: 50));

      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];

        if (!error) {
          var data = getdata["data"];
          chatList = (data as List).map((data) => new ChatModel.fromJson(data)).toList();
        } else {
          if (msg != "Ticket Message(s) does not exist") UiUtils.setSnackBar(StringsRes.message, msg!, context, false);
        }
        if (mounted) setState(() {});
      }
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(StringsRes.message, 'somethingMSg', context, false);
    }
  }

  msgRow() {
    return widget.status != "4"
        ? Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              width: double.infinity,
              color: ColorsRes.white,
              child: Row(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      _imgFromGallery();
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: ColorsRes.backgroundDark,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: ColorsRes.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      controller: msgController,
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(color: ColorsRes.backgroundDark),
                      maxLines: null,
                      decoration: const InputDecoration(
                          hintText: "Write message...", hintStyle: TextStyle(color: ColorsRes.backgroundDark), border: InputBorder.none),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      if (msgController.text.trim().length > 0 || files.length > 0) {
                        sendMessage(msgController.text.trim());
                      }
                    },
                    child: const Icon(
                      Icons.send,
                      color: ColorsRes.white,
                      size: 18,
                    ),
                    backgroundColor: ColorsRes.backgroundDark,
                    elevation: 0,
                  ),
                ],
              ),
            ),
          )
        : Container();
  }

  Widget attachItem(List<Attachments> attach, int index, ChatModel message) {
    String? file = attach[index].media;
    String? type = attach[index].type;
    String icon;
    if (type == "video") {
      icon = "assets/images/video.png";
    } else if (type == "document") {
      icon = "assets/images/doc.png";
    } else if (type == "spreadsheet") {
      icon = "assets/images/sheet.png";
    } else {
      icon = "assets/images/zip.png";
    }
    return FutureBuilder<List<Directory>?>(
        future: _externalStorageDirectories,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return file == null
              ? Container()
              : Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    Card(
                      //margin: EdgeInsets.only(right: message.sender_id == myid ? 10 : 50, left: message.sender_id == myid ? 50 : 10, bottom: 10),
                      elevation: 0.0,
                      color:
                          message.userId == context.read<AuthCubit>().getId() ? ColorsRes.backgroundDark.withOpacity(0.1) : ColorsRes.greyLightColor,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: message.userId == context.read<AuthCubit>().getId() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: <Widget>[
                            //_messages[index].issend ? Container() : Center(child: SizedBox(height:20,width: 20,child: new CircularProgressIndicator(backgroundColor: ColorsRes.secondgradientcolor,))),

                            InkWell(
                              onTap: () {
                                _requestDownload(attach[index].media, message.id, snapshot);
                              },
                              child: type == "image"
                                  ? Image.network(file,
                                      width: 250,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Image.asset(DesignConfig.setPngPath('placeholder_square'), height: 150, width: 150))
                                  : Image.asset(
                                      icon,
                                      width: 100,
                                      height: 100,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text(message.dateCreated!, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 9)),
                      ),
                    ),
                  ],
                );
        });
  }
}
