// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:blur/blur.dart';
import 'package:chewie/chewie.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:emoji_choose/emoji_choose.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:kiranapp/screens/EmojiPickerWidget.dart';
import 'package:kiranapp/screens/widgets/add_people_dialog.dart';
import 'package:kiranapp/screens/widgets/admin_alert_bubble_widget.dart';
import 'package:kiranapp/screens/widgets/drag_and_drop_widget.dart';
import 'package:kiranapp/screens/widgets/edit_group.dart';
import 'package:kiranapp/screens/widgets/file_send_widget.dart';
import 'package:kiranapp/screens/widgets/group_office_staff_users.dart';
import 'package:kiranapp/screens/widgets/group_users.dart';
import 'package:kiranapp/screens/widgets/image_post_widget.dart';
import 'package:kiranapp/screens/widgets/message_reply_bubble.dart';
import 'package:kiranapp/screens/widgets/remove_people_dialog.dart';
import 'package:kiranapp/screens/widgets/transfer_users.dart';
import 'package:kiranapp/screens/widgets/video_chat_bubble.dart';
import 'package:kiranapp/screens/widgets/yes_or_no.dart';
import 'package:kiranapp/services/send_notification.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:mime/mime.dart';
import 'package:rolling_switch/rolling_switch.dart';
import 'package:video_player/video_player.dart';
import 'package:web_smooth_scroll/web_smooth_scroll.dart';
import '../controllers/app_controller.dart';
import '../design/app_colors.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../model/chat_message.dart';
import 'widgets/DropZoneWidget.dart';
import 'widgets/DroppedFileWidget.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/export_data_widget.dart';
import 'widgets/file_bubble.dart';
import 'widgets/image_chat_bubble.dart';
import 'widgets/image_chat_bubble.dart';
import 'widgets/link_bubble.dart';
import 'widgets/model/file_DataModel.dart';
import 'widgets/yes_or_no_clear_group_messages.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum MessageType {
  Sender,
  Receiver,
}

enum Category {
  Normal,
  Group,
}

class ChatScreenWidget extends StatefulWidget {
  const ChatScreenWidget({Key? key, required this.groupId}) : super(key: key);

  final String groupId;

  @override
  State<ChatScreenWidget> createState() => _ChatScreenWidgetState();
}

class _ChatScreenWidgetState extends State<ChatScreenWidget> {
  bool _switchValue = false;
  final _firestore = FirebaseFirestore.instance;
  final box = GetStorage();
  final messageController = TextEditingController();
  late FocusNode myFocusNode;

  @override
  void initState() {
    myFocusNode = FocusNode();
  }

  // final ScrollController _scrollController;
  bool isLoading = false;
  final videoUrlController = TextEditingController();
  AppControllers appcontroller = Get.put(AppControllers());
  var focusNode = FocusNode();
  String? groupName;
  bool isKeyboardVisible = false;
  bool isEmojiVisible = false;

  void onEmojiSelected(String emoji) => setState(() {
        //controller.text = controller.messageController!.text + emoji;
      });
  Widget buildEmoji() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
          onPressed: () {
            if (isKeyboardVisible) {
              FocusScope.of(context).unfocus();
            }
            setState(() {
              isEmojiVisible = !isEmojiVisible;
            });
          },
          icon: const Icon(
            Icons.emoji_emotions_outlined,
            color: Colors.white,
          )));

  File_Data_Model? file;
  ScrollController _scrollController = ScrollController();

  late DropzoneViewController dropController;
  bool highlight = false;

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    await _firestore
        .collection('users')
        .doc(box.read('id'))
        .get()
        .then((info) async {
      box.write('username', info['username']);
    });

    // initialize scroll controllers
    _scrollController = ScrollController();
    // await _firestore
    //     .collection('groups')
    //     .doc(widget.groupId)
    //     .get()
    //     .then((info) async {
    //   setState(() {
    //     _switchValue = info['isOff'];
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 3,
      child: Container(
        color: Palette.appColor,
        child: Column(
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.groupId)
                  .snapshots(),
              builder: (context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                      snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }
                final data = snapshot.data!.data();
                if (data!['type'] == 'group') {
                  box.write('isGroup', true);
                } else {
                  box.write('isGroup', false);
                }
                groupName = data['groupName'];
                return AppBar(
                  toolbarHeight: 70.h,
                  backgroundColor: Palette.secondColor,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 25.0,
                      child: CircleAvatar(
                        backgroundColor: Palette.appColor,
                        radius: 23.0,
                        child: data['type'] == 'group'
                            ? const Icon(
                                Icons.groups,
                              )
                            : const Icon(
                                Icons.announcement,
                              ),
                      ),
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        data['groupName'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                      // const SelectableText(
                      //   'Last seen 2:00 AM',
                      //   style: TextStyle(
                      //     color: Colors.grey,
                      //     fontSize: 15.0,
                      //   ),
                      // )
                    ],
                  ),
                  actions: [
                    box.read('isAdmin')
                        ? IconButton(
                            onPressed: () {
                              Get.dialog(
                                Center(
                                  child: SendAlertWidget(
                                    groupId: widget.groupId,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.info_outline_rounded,
                            ),
                          )
                        : const SizedBox(),
                    box.read('isAdmin')
                        ? StreamBuilder(
                            stream: _firestore
                                .collection('groups')
                                .doc(widget.groupId)
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<
                                        DocumentSnapshot<Map<String, dynamic>>>
                                    snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox();
                              }
                              final data = snapshot.data!.data();
                              return Transform.scale(
                                scale: 0.7,
                                child: RollingSwitch.icon(
                                  onChanged: (bool state) async {
                                    await _firestore
                                        .collection('groups')
                                        .doc(widget.groupId)
                                        .update({
                                      'isOff': state,
                                    });
                                  },
                                  rollingInfoRight: const RollingIconInfo(
                                    icon: Icons.check,
                                    text: Text(
                                      'On',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                      ),
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                  initialState: data!['isOff'],
                                  rollingInfoLeft: const RollingIconInfo(
                                    icon: Icons.close,
                                    backgroundColor: Colors.red,
                                    text: Text(
                                      'Off',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            })
                        : const SizedBox(),
                    // IconButton(
                    //   onPressed: () {},
                    //   icon: const Icon(
                    //     Icons.search,
                    //     color: Colors.white60,
                    //   ),
                    // ),
                    box.read('Office_Staff')! ?  PopupMenuButton<String>(
                      color: Colors.transparent,
                      elevation: 0.0,
                      itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        PopupMenuItem(
                          enabled: false, // DISABLED THIS ITEM
                          child: GlassmorphicContainer(
                            borderRadius: 20,
                            blur: 5,
                            padding: const EdgeInsets.all(40),
                            alignment: Alignment.bottomCenter,
                            border: 0,
                            linearGradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF1b242b).withOpacity(0.7),
                                const Color(0xFF1b242b).withOpacity(0.7),
                              ],
                              stops: const [
                                0.1,
                                1,
                              ],
                            ),
                            borderGradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                //for border..........................................................
                                const Color(0xFF1b242b).withOpacity(0.5),
                                const Color((0xFF1b242b))
                                    .withOpacity(0.5),
                              ],
                            ),
                            height: 340.h,
                            width: 250.w,
                            child: Column(
                              children: [
                                Visibility(
                                  visible:box.read("Office_Staff"),
                                  child: Flexible(
                                    child: ListTile(
                                      onTap: () {
                                        Get.dialog(
                                          Center(
                                            child: GroupOfficeStaffUsersDialog(
                                              groupId: widget.groupId,
                                            ),
                                          ),
                                        );
                                      },
                                      shape: const StadiumBorder(),
                                      leading: const Icon(
                                        Icons.groups_rounded,
                                        color: Colors.white,
                                      ),
                                      title: Text('Office Staff',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.more_vert,
                          color: Colors.white60,
                        ),
                      ),
                    ): box.read('isAdmin')!
                        ? PopupMenuButton<String>(
                            color: Colors.transparent,
                            elevation: 0.0,
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              PopupMenuItem(
                                enabled: false, // DISABLED THIS ITEM
                                child: GlassmorphicContainer(
                                  borderRadius: 20,
                                  blur: 5,
                                  padding: const EdgeInsets.all(40),
                                  alignment: Alignment.bottomCenter,
                                  border: 0,
                                  linearGradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF1b242b).withOpacity(0.7),
                                      const Color(0xFF1b242b).withOpacity(0.7),
                                    ],
                                    stops: const [
                                      0.1,
                                      1,
                                    ],
                                  ),
                                  borderGradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      //for border..........................................................
                                      const Color(0xFF1b242b).withOpacity(0.5),
                                      const Color((0xFF1b242b))
                                          .withOpacity(0.5),
                                    ],
                                  ),
                                  height: 340.h,
                                  width: 250.w,
                                  child: Column(
                                    children: [
                                      Flexible(
                                        child: ListTile(
                                          onTap: () {
                                            Get.dialog(Center(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                child: Container(
                                                  height: 300.h,
                                                  width: 300.w,
                                                  color: Palette.secondColor,
                                                  child: Scaffold(
                                                    backgroundColor:
                                                        Palette.secondColor,
                                                    appBar: AppBar(
                                                      backgroundColor:
                                                          Palette.mainColor,
                                                      title: box.read('isGroup')
                                                          ? const Text(
                                                              'Manage Group')
                                                          : const Text(
                                                              'Manage Channel'),
                                                      elevation: 0.0,
                                                      automaticallyImplyLeading:
                                                          false,
                                                    ),
                                                    body: Column(
                                                      children: [
                                                        ListTile(
                                                          onTap: () {
                                                            Get.dialog(
                                                              Center(
                                                                child:
                                                                    AddPeopleDialog(
                                                                  groupId: widget
                                                                      .groupId,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          leading: const Icon(
                                                            Icons.person_add,
                                                            color: Colors.white,
                                                          ),
                                                          title: const Text(
                                                            'Add People',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                        ListTile(
                                                          onTap: () {
                                                            Get.dialog(
                                                              Center(
                                                                child:
                                                                    RemovePeopleDialog(
                                                                  groupId: widget
                                                                      .groupId,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          leading: const Icon(
                                                            Icons.person_remove,
                                                            color: Colors.white,
                                                          ),
                                                          title: const Text(
                                                            'Remove People',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                        ListTile(
                                                          onTap: () {
                                                            Get.dialog(
                                                              Center(
                                                                child:
                                                                    EditGroup(
                                                                      groupId: widget.groupId,
                                                                      groupName: data['groupName'],
                                                                    ),
                                                              ),
                                                            );
                                                          },
                                                          leading: const Icon(
                                                            Icons.edit,
                                                            color: Colors.white,
                                                          ),
                                                          title: box.read(
                                                                  'isGroup')
                                                              ? const Text(
                                                                  'Edit Group Info',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                )
                                                              : const Text(
                                                                  'Edit Channel Info',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                        ),
                                                        box.read('isGroup')
                                                            ? ListTile(
                                                                onTap: () {
                                                                  Get.dialog(
                                                                    Center(
                                                                      child:
                                                                          ExportDataWidget(
                                                                        groupId:
                                                                            widget.groupId,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                leading:
                                                                    const Icon(
                                                                  Icons
                                                                      .ios_share,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                title:
                                                                    const Text(
                                                                  'Export Group Data',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              )
                                                            : const SizedBox(),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ));
                                          },
                                          shape: const StadiumBorder(),
                                          leading: const Icon(
                                            Icons.manage_accounts,
                                            color: Colors.white,
                                          ),
                                          title: Text(
                                            box.read('isGroup')
                                                ? 'Manage Group'
                                                : 'Manage Channel',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: ListTile(
                                          onTap: () {
                                            Get.dialog(
                                              Center(
                                                child: GroupUsersDialog(
                                                  groupId: widget.groupId,
                                                ),
                                              ),
                                            );
                                          },
                                          shape: const StadiumBorder(),
                                          leading: const Icon(
                                            Icons.groups_rounded,
                                            color: Colors.white,
                                          ),
                                          title: Text(
                                            box.read('isGroup')
                                                ? 'Group Users'
                                                : 'Channel Users',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                          child: ListTile(
                                            onTap: () {
                                              Get.dialog(
                                                Center(
                                                  child: GroupOfficeStaffUsersDialog(
                                                    groupId: widget.groupId,
                                                  ),
                                                ),
                                              );
                                            },
                                            shape: const StadiumBorder(),
                                            leading: const Icon(
                                              Icons.groups_rounded,
                                              color: Colors.white,
                                            ),
                                            title: Text('Office Staff',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      Flexible(
                                        child: ListTile(
                                          onTap: () {
                                            Get.dialog(
                                              Center(
                                                child: TransferUsers(
                                                  groupId: widget.groupId,
                                                ),
                                              ),
                                            );//lucky bhai zindabaad
                                          },
                                          shape: const StadiumBorder(),
                                          leading: const Icon(
                                            Icons.group,
                                            color: Colors.white,
                                          ),
                                          title: const Text(
                                            'Transfer Users',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: ListTile(
                                          onTap: () {
                                            Get.dialog(
                                              Center(
                                                child:
                                                    YesOrNoClearGroupMessagesWidget(
                                                  groupId: widget.groupId,
                                                  isOneChat: false,
                                                ),
                                              ),
                                            );
                                          },
                                          shape: const StadiumBorder(),
                                          leading: const Icon(
                                            Icons.clear,
                                            color: Colors.white,
                                          ),
                                          title: Text(
                                            box.read('isGroup')
                                                ? 'Clear Group messages'
                                                : 'Clear Channel messages',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: ListTile(
                                          onTap: () {
                                            // Get.dialog();
                                            Get.dialog(
                                              Center(
                                                child: YesOrNoWidget(
                                                  groupId: widget.groupId,
                                                ),
                                              ),
                                            );
                                          },
                                          shape: const StadiumBorder(),
                                          leading: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                          title: Text(
                                            box.read('isGroup')
                                                ? 'Delete Group'
                                                : 'Delete Channel',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.more_vert,
                                color: Colors.white60,
                              ),
                            ),
                          )
                        :  const SizedBox(),
                  ],
                );
              },
            ),
            Expanded(
              child: StreamBuilder(
                  stream: _firestore
                      .collection('groups')
                      .doc(widget.groupId) 
                      .snapshots(),
                  builder: (context,
                      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                          snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    }
                    final data = snapshot.data!.data();
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 180.w,
                      ),
                      child: GetBuilder<AppControllers>(
                        builder: (controller) {
                          return Stack(
                            children: [
                              DropzoneView(
                                onCreated: (controller) =>
                                    dropController = controller,
                                onDrop: (event) async {
                                  final name = event.name;

                                  final mime =
                                      await dropController.getFileMIME(event);
                                  final byte =
                                      await dropController.getFileSize(event);
                                  final url =
                                      await dropController.createFileUrl(event);
                                  final fileData =
                                      await dropController.getFileData(event);
                                  print('Name : $name');
                                  print('Mime: $mime');

                                  print('Size : ${byte / (1024 * 1024)}');
                                  print('URL: $url');

                                  final droppedFile = File_Data_Model(
                                      name: name,
                                      mime: mime,
                                      bytes: byte,
                                      url: url);

                                  // widget.onDroppedFile(droppedFile);
                                  setState(() {
                                    highlight = false;
                                  });

                                  Get.dialog(Center(
                                      child: ImagePostWidget(
                                    groupId: widget.groupId,
                                    isDrop: true,
                                    data: fileData,
                                  )));
                                },
                                onHover: () => setState(() => highlight = true),
                                onLeave: () =>
                                    setState(() => highlight = false),
                              ),
                              Container(
                                color: Palette.searchTextFieldColor,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: StreamBuilder<QuerySnapshot>(
                                        stream: _firestore
                                            .collection('groups')
                                            .doc(widget.groupId)
                                            .collection('groupMessages')
                                            .orderBy(
                                              'time',
                                              descending: false,
                                            )
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return const Text(
                                                'Something went wrong');
                                          }

                                          if (!snapshot.hasData) {
                                            return const Text('Loading');
                                          }

                                          // if (snapshot.connectionState ==
                                          //     ConnectionState.waiting) {
                                          //   return Center(
                                          //     child: Text(
                                          //       "Loading",
                                          //       style: TextStyle(
                                          //         color: Palette.mainColor,
                                          //       ),
                                          //     ),
                                          //   );
                                          // }

                                          List<ChatMessage> chatMessage = [];
                                          List<ChatMessage> chatMessagesTime =
                                              [];

                                          String? currentDate;

                                          for (var doc in snapshot.data!.docs) {
                                            if (formatDate(doc['time'].toDate(),
                                                    [yy, '-', M, '-', d]) !=
                                                currentDate) {
                                              chatMessage.add(
                                                ChatMessage(
                                                  message: formatDate(
                                                              doc['time']
                                                                  .toDate(),
                                                              [M, ' ', d]) ==
                                                          formatDate(
                                                              DateTime.now(),
                                                              [M, ' ', d])
                                                      ? "TODAY"
                                                      : formatDate(
                                                          doc['time'].toDate(),
                                                          [M, ' ', d]),
                                                  type: doc["senderId"] ==
                                                          box.read('id')
                                                      ? MessageType.Sender
                                                      : MessageType.Receiver,
                                                  messageType: 'time',
                                                  cat: Category.Group,
                                                  userImage: '',
                                                  userName: doc["senderName"],
                                                  time: doc["time"],
                                                  imageUrl: '',
                                                  videoUrl: '',
                                                  thumbnail: '',
                                                  id: doc["senderId"],
                                                  msgId: doc.id,
                                                  groupId: widget.groupId,
                                                  data: doc,
                                                ),
                                              );
                                              currentDate = formatDate(
                                                  doc['time'].toDate(),
                                                  [yy, '-', M, '-', d]);
                                            } else {
                                              currentDate = formatDate(
                                                  doc['time'].toDate(),
                                                  [yy, '-', M, '-', d]);
                                            }

                                            if (doc["type"] == 'text') {
                                              chatMessage.add(
                                                ChatMessage(
                                                  message: doc["message"],
                                                  type: doc["senderId"] ==
                                                          box.read('id')
                                                      ? MessageType.Sender
                                                      : MessageType.Receiver,
                                                  messageType: 'text',
                                                  cat: Category.Group,
                                                  userImage: '',
                                                  userName: doc["senderName"],
                                                  time: doc["time"],
                                                  imageUrl: '',
                                                  videoUrl: '',
                                                  thumbnail: '',
                                                  id: doc["senderId"],
                                                  msgId: doc.id,
                                                  groupId: widget.groupId,
                                                  data: doc,
                                                ),
                                              );
                                            } else if (doc["type"] == 'file') {
                                              chatMessage.add(
                                                ChatMessage(
                                                  message: '',
                                                  type: doc["senderId"] ==
                                                          box.read('id')
                                                      ? MessageType.Sender
                                                      : MessageType.Receiver,
                                                  messageType: 'file',
                                                  cat: Category.Group,
                                                  userImage: '',
                                                  userName: doc["senderName"],
                                                  time: doc["time"],
                                                  imageUrl: '',
                                                  videoUrl: '',
                                                  thumbnail: '',
                                                  id: doc["senderId"],
                                                  msgId: doc.id,
                                                  groupId: widget.groupId,
                                                  data: doc,
                                                ),
                                              );
                                            } else if (doc["type"] == 'video') {
                                              chatMessage.add(
                                                ChatMessage(
                                                  message: doc["message"],
                                                  type: doc["senderId"] ==
                                                          box.read('id')
                                                      ? MessageType.Sender
                                                      : MessageType.Receiver,
                                                  messageType: 'video',
                                                  cat: Category.Group,
                                                  userImage: '',
                                                  userName: doc["senderName"],
                                                  time: doc["time"],
                                                  imageUrl: '',
                                                  videoUrl: doc["videoUrl"],
                                                  thumbnail: doc["thumbnail"],
                                                  id: doc["senderId"],
                                                  msgId: doc.id,
                                                  groupId: widget.groupId,
                                                  data: doc,
                                                ),
                                              );
                                            } else if (doc["type"] == 'image') {
                                              chatMessage.add(
                                                ChatMessage(
                                                  message: doc["message"],
                                                  type: doc["senderId"] ==
                                                          box.read('id')
                                                      ? MessageType.Sender
                                                      : MessageType.Receiver,
                                                  messageType: 'image',
                                                  cat: Category.Group,
                                                  userImage: '',
                                                  userName: doc["senderName"],
                                                  time: doc["time"],
                                                  imageUrl: doc["imageUrl"],
                                                  videoUrl: '',
                                                  thumbnail: '',
                                                  id: doc["senderId"],
                                                  msgId: doc.id,
                                                  groupId: widget.groupId,
                                                  data: doc,
                                                ),
                                              );
                                            } else if (doc["type"] == 'link') {
                                              chatMessage.add(
                                                ChatMessage(
                                                  message: doc["message"],
                                                  type: doc["senderId"] ==
                                                          box.read('id')
                                                      ? MessageType.Sender
                                                      : MessageType.Receiver,
                                                  messageType: 'link',
                                                  cat: Category.Group,
                                                  userImage: '',
                                                  userName: doc["senderName"],
                                                  time: doc["time"],
                                                  imageUrl: '',
                                                  videoUrl: '',
                                                  thumbnail: '',
                                                  id: doc["senderId"],
                                                  msgId: doc.id,
                                                  groupId: widget.groupId,
                                                  data: doc,
                                                ),
                                              );
                                            } else if (doc["type"] == 'reply') {
                                              chatMessage.add(
                                                ChatMessage(
                                                  message: doc["message"],
                                                  type: doc["senderId"] ==
                                                          box.read('id')
                                                      ? MessageType.Sender
                                                      : MessageType.Receiver,
                                                  messageType: 'reply',
                                                  cat: Category.Group,
                                                  userImage: '',
                                                  userName: doc["senderName"],
                                                  time: doc["time"],
                                                  imageUrl: '',
                                                  videoUrl: '',
                                                  thumbnail: '',
                                                  id: doc["senderId"],
                                                  msgId: doc.id,
                                                  groupId: widget.groupId,
                                                  data: doc,
                                                ),
                                              );
                                            } else if (doc["type"] == 'alert') {
                                              chatMessage.add(
                                                ChatMessage(
                                                  message: doc["message"],
                                                  type: doc["senderId"] ==
                                                          box.read('id')
                                                      ? MessageType.Sender
                                                      : MessageType.Receiver,
                                                  messageType: 'alert',
                                                  cat: Category.Group,
                                                  userImage: '',
                                                  userName: doc["senderName"],
                                                  time: doc["time"],
                                                  imageUrl: '',
                                                  videoUrl: '',
                                                  thumbnail: '',
                                                  id: doc["senderId"],
                                                  msgId: doc.id,
                                                  groupId: widget.groupId,
                                                  data: doc,
                                                ),
                                              );
                                            }
                                          }
                                          chatMessagesTime =
                                              chatMessage.reversed.toList();
                                          return Scrollbar(
                                            controller: _scrollController,
                                            child: ListView.builder(
                                              controller: _scrollController,
                                              itemCount:
                                                  chatMessagesTime.length,
                                              shrinkWrap: true,
                                              reverse: true,
                                              padding: const EdgeInsets.only(
                                                top: 10,
                                                bottom: 10,
                                              ),
                                              physics: const ScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                // ignore: unrelated_type_equality_checks
                                                return chatMessagesTime[index]
                                                            .messageType ==
                                                        'time'
                                                    ? Center(
                                                        child: Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                            vertical: 10.h,
                                                          ),
                                                          child: SizedBox(
                                                            height: 35.h,
                                                            width: 70.w,
                                                            child: Material(
                                                              color: Colors
                                                                  .yellow[100],
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30.0),
                                                              child: Center(
                                                                child: Text(
                                                                  chatMessagesTime[
                                                                          index]
                                                                      .message,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                            .yellow[
                                                                        900],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : chatMessagesTime[index]
                                                                .messageType ==
                                                            'text'
                                                        ? ChatBubble(
                                                            chatMessage:
                                                                chatMessagesTime[
                                                                    index],
                                                            groupId:
                                                                widget.groupId,
                                                          )
                                                        : chatMessagesTime[
                                                                        index]
                                                                    .messageType ==
                                                                'file'
                                                            ? FileBubble(
                                                                chatMessage:
                                                                    chatMessagesTime[
                                                                        index],
                                                                groupId: widget
                                                                    .groupId,
                                                              )
                                                            : chatMessagesTime[
                                                                            index]
                                                                        .messageType ==
                                                                    'alert'
                                                                ? AdminAlertBubbleWidget(
                                                                    chatMessage:
                                                                        chatMessagesTime[
                                                                            index],
                                                                    groupId: widget
                                                                        .groupId,
                                                                  )
                                                                : chatMessagesTime[index]
                                                                            .messageType ==
                                                                        'image'
                                                                    ? ImageChatBubble(
                                                                        chatMessage:
                                                                            chatMessagesTime[index],
                                                                        groupId:
                                                                            widget.groupId,
                                                                      )
                                                                    : chatMessagesTime[index].messageType ==
                                                                            'link'
                                                                        ? LinkBubble(
                                                                            chatMessage:
                                                                                chatMessagesTime[index],
                                                                            groupId:
                                                                                widget.groupId,
                                                                          )
                                                                        : chatMessagesTime[index].messageType ==
                                                                                'reply'
                                                                            ? MessageReplyBubble(
                                                                                text: chatMessagesTime[index].data["message"],
                                                                                isMe: chatMessagesTime[index].data["senderId"] == box.read('id') ? true : false,
                                                                                time: chatMessagesTime[index].data["time"],
                                                                                documentID: chatMessagesTime[index].msgId,
                                                                                isStarred: false,
                                                                                replyId: chatMessagesTime[index].data["replyId"],
                                                                                groupId: widget.groupId,
                                                                                senderId: chatMessagesTime[index].data["senderId"],
                                                                                username: chatMessagesTime[index].userName,
                                                                                chatMessage: chatMessagesTime[index],
                                                                              )
                                                                            : VideoChatBubble(
                                                                                chatMessage: chatMessagesTime[index],
                                                                              );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    controller.isMessageEdit ||
                                            controller.isMessageReply
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            child: Container(
                                              color: Colors.blueGrey[900],
                                              height: 50.h,
                                              width: 300.w,
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      if (controller
                                                          .isMessageEdit) {
                                                        Get.find<
                                                                AppControllers>()
                                                            .textFieldClear();
                                                        Get.find<
                                                                AppControllers>()
                                                            .setMessageEdit(
                                                                isEdit: false,
                                                                msgId: '');
                                                      } else {
                                                        Get.find<
                                                                AppControllers>()
                                                            .setMessageReply(
                                                          isReply: false,
                                                          msgId: '',
                                                          message: '',
                                                          username: '',
                                                        );
                                                      }
                                                    },
                                                    icon: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                      controller.isMessageEdit
                                                          ? 'Editing Message'
                                                          : 'Message Reply to ${controller.replyUsername}: ${controller.replymessage}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                    StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection('groups')
                                            .doc(widget.groupId)
                                            .snapshots(),
                                        builder: (context,
                                            AsyncSnapshot<
                                                    DocumentSnapshot<
                                                        Map<String, dynamic>>>
                                                snapshot) {
                                          if (!snapshot.hasData) {
                                            return const SizedBox();
                                          }
                                          final groupData =
                                              snapshot.data!.data();
                                          return Container(
                                            // height: 8.h,
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(
                                              12.0,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 2.w,
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Palette
                                                        .searchTextFieldColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0)),
                                                child:
                                                    box.read('isAdmin') !=
                                                                true &&
                                                            groupData![
                                                                    'type'] ==
                                                                'announcement'
                                                        ? SizedBox(
                                                            child: Center(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const Text(
                                                                    'Announcement channel',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          20.0,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5.w,
                                                                  ),
                                                                  const Icon(
                                                                    Icons
                                                                        .announcement,
                                                                    color: Colors
                                                                        .grey,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              // Flexible(
                                                              //   child: Container(
                                                              //     margin: const EdgeInsets.all(8.0),
                                                              //     child: const Icon(
                                                              //       Icons.emoji_emotions,
                                                              //       color: Colors.white60,
                                                              //     ),
                                                              //   ),
                                                              // ),
                                                              Flexible(
                                                                  flex: 1,
                                                                  child:
                                                                      buildEmoji()),
                                                              Flexible(
                                                                flex: 5,
                                                                child:
                                                                    RawKeyboardListener(
                                                                  focusNode: FocusNode(
                                                                      onKey: (node,
                                                                          event) {
                                                                    if (((event.isKeyPressed(LogicalKeyboardKey.enter)) ||
                                                                            (event.isKeyPressed(LogicalKeyboardKey
                                                                                .numpadEnter))) &&
                                                                        !event
                                                                            .isShiftPressed) {
                                                                      if (kDebugMode) {
                                                                        print(
                                                                            "working21");
                                                                      }

                                                                      return KeyEventResult
                                                                          .handled; // prevent passing the event into the TextField
                                                                    }
                                                                    return KeyEventResult
                                                                        .ignored; // pass the event to the TextField
                                                                  }),
                                                                  onKey:
                                                                      (event) async {
                                                                    if (event
                                                                        is RawKeyDownEvent) {
                                                                      if (((event.isKeyPressed(LogicalKeyboardKey.enter)) ||
                                                                              (event.isKeyPressed(LogicalKeyboardKey.numpadEnter))) &&
                                                                          !event.isShiftPressed) {
                                                                        // Do something
                                                                        String messageText = controller
                                                                            .messageController!
                                                                            .text;
                                                                        if (controller.messageController!.text.isNotEmpty &&
                                                                            controller.messageController!.text.trim() !=
                                                                                '') {
                                                                          String
                                                                              message =
                                                                              controller.messageController!.text;
                                                                          // clear textfield
                                                                          Get.find<AppControllers>()
                                                                              .setTextFieldController(text: '');

                                                                          if (controller
                                                                              .isMessageEdit) {
                                                                            await _firestore.collection('groups').doc(widget.groupId).collection('groupMessages').doc(controller.editMessageId).update({
                                                                              'message': message,
                                                                              'messageIndex': groupData!['messageIndex'] + 1,
                                                                            });

                                                                            // Get.find<
                                                                            //         AppControllers>()
                                                                            //     .textFieldClear();
                                                                            Get.find<AppControllers>().setMessageEdit(
                                                                                isEdit: false,
                                                                                msgId: '');
                                                                          } else if (controller
                                                                              .isMessageReply) {
                                                                            await _firestore.collection('groups').doc(widget.groupId).collection('groupMessages').doc().set({
                                                                              'message': message,
                                                                              'senderId': box.read('id'),
                                                                              'senderImage': null,
                                                                              'senderName': box.read('username'),
                                                                              'senderPhone': box.read('phone'),
                                                                              'type': 'reply',
                                                                              'replyId': controller.replymessageId,
                                                                              'groupId': widget.groupId,
                                                                              'new': true,
                                                                              'seenBy': [],
                                                                              'time': DateTime.now(),
                                                                              'messageIndex': groupData!['messageIndex'] + 1,
                                                                            });
                                                                            await _firestore.collection('groups').doc(widget.groupId).update({
                                                                              'message': message,
                                                                              'messageIndex': groupData['messageIndex'] + 1,
                                                                            });
                                                                            Get.find<AppControllers>().setMessageReply(
                                                                                isReply: false,
                                                                                msgId: '',
                                                                                message: '',
                                                                                username: '');

                                                                            print("KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKk");
                                                                            controller.focusNode.unfocus();
                                                                            // FocusScope.of(context).previousFocus();
                                                                            // controller.setInputFocus();

                                                                            // SendNotif.sendPushMessageToWeb(
                                                                            //     groupId: widget
                                                                            //         .groupId,
                                                                            //     message:
                                                                            //         messageText,
                                                                            //     groupName:
                                                                            //         groupName!);
                                                                            // Get.find<
                                                                            //         AppControllers>()
                                                                            //     .textFieldClear();
                                                                          } else {
                                                                            await _firestore.collection('groups').doc(widget.groupId).collection('groupMessages').doc().set({
                                                                              'message': message,
                                                                              'senderId': box.read('id'),
                                                                              'senderImage': null,
                                                                              'senderName': box.read('username'),
                                                                              'senderPhone': box.read('phone'),
                                                                              'type': 'text',
                                                                              'new': true,
                                                                              'seenBy': [],
                                                                              'time': DateTime.now(),
                                                                              'messageIndex': groupData!['messageIndex'] + 1,
                                                                            });
                                                                            await _firestore.collection('groups').doc(widget.groupId).update({
                                                                              'message': message,
                                                                              'messageIndex': groupData['messageIndex'] + 1,
                                                                            });
                                                                            Get.find<AppControllers>().setInputFocus();
                                                                            // SendNotif.sendPushMessageToWeb(
                                                                            //     groupId: widget
                                                                            //         .groupId,
                                                                            //     message:
                                                                            //         messageText,
                                                                            //     groupName:
                                                                            //         groupName!);
                                                                          }

                                                                          // _scrollController.animateTo(
                                                                          //   0.0,
                                                                          //   curve: Curves.easeOut,
                                                                          //   duration:
                                                                          //       const Duration(milliseconds: 300),
                                                                          // );
                                                                        }
                                                                      }
                                                                    }
                                                                  },
                                                                  child:
                                                                      TextField(
                                                                    autofocus:
                                                                        true,
                                                                    controller:
                                                                        controller
                                                                            .messageController,
                                                                    readOnly: data!['isOff'] ==
                                                                                true &&
                                                                            box.read('isAdmin') !=
                                                                                true
                                                                        ? false
                                                                        : false,
                                                                    focusNode:
                                                                        controller
                                                                            .focusNode,
                                                                    maxLines:
                                                                        null,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                    onChanged:
                                                                        (text) {
                                                                      print(
                                                                          'First text field: $text');
                                                                      FlutterClipboard
                                                                              .paste()
                                                                          .then(
                                                                              (value) {
                                                                        // Do what ever you want with the value.

                                                                        print(
                                                                            'First text field FlutterClipboard: $value');
                                                                        /*setState(() {
                                                                field.text = value;
                                                                pasteValue = value;
                                                              });*/
                                                                      });
                                                                    },
                                                                    decoration:
                                                                        InputDecoration(
                                                                      hintText:
                                                                          'Type message...',
                                                                      hintStyle:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .white60,
                                                                        fontWeight:
                                                                            FontWeight.w100,
                                                                        fontSize:
                                                                            17,
                                                                      ),
                                                                      border: OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(20)),
                                                                      enabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide:
                                                                            const BorderSide(
                                                                          color:
                                                                              Colors.transparent,
                                                                          width:
                                                                              0.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(20),
                                                                      ),
                                                                      focusedBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide:
                                                                            const BorderSide(
                                                                          color:
                                                                              Colors.transparent,
                                                                          width:
                                                                              0.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(20),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Flexible(
                                                                child:
                                                                    Container(
                                                                  margin:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child:
                                                                      PopupMenuButton<
                                                                          String>(
                                                                    color: Colors
                                                                        .transparent,
                                                                    elevation:
                                                                        0.0,
                                                                    tooltip:
                                                                        'Attach File',
                                                                    enabled: data['isOff'] ==
                                                                                true &&
                                                                            box.read('isAdmin') !=
                                                                                true
                                                                        ? false
                                                                        : true,
                                                                    itemBuilder:
                                                                        (BuildContext
                                                                                context) =>
                                                                            <PopupMenuEntry<String>>[
                                                                      PopupMenuItem(
                                                                        enabled:
                                                                            false,
                                                                        // DISABLED THIS ITEM
                                                                        child:
                                                                            GlassmorphicContainer(
                                                                          borderRadius:
                                                                              20,
                                                                          blur:
                                                                              5,
                                                                          padding:
                                                                              const EdgeInsets.all(40),
                                                                          alignment:
                                                                              Alignment.bottomCenter,
                                                                          border:
                                                                              0,
                                                                          linearGradient:
                                                                              LinearGradient(
                                                                            begin:
                                                                                Alignment.topLeft,
                                                                            end:
                                                                                Alignment.bottomRight,
                                                                            colors: [
                                                                              const Color(0xFF1b242b).withOpacity(0.7),
                                                                              const Color(0xFF1b242b).withOpacity(0.7),
                                                                            ],
                                                                            stops: const [
                                                                              0.1,
                                                                              1,
                                                                            ],
                                                                          ),
                                                                          borderGradient:
                                                                              LinearGradient(
                                                                            begin:
                                                                                Alignment.topLeft,
                                                                            end:
                                                                                Alignment.bottomRight,
                                                                            colors: [
                                                                              //for border..........................................................
                                                                              const Color(0xFF1b242b).withOpacity(0.5),
                                                                              const Color((0xFF1b242b)).withOpacity(0.5),
                                                                            ],
                                                                          ),
                                                                          height:
                                                                              150.h,
                                                                          width:
                                                                              200.w,
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              Flexible(
                                                                                child: ListTile(
                                                                                  onTap: () async {
                                                                                    Get.dialog(
                                                                                      Center(
                                                                                        child: SendVideoLinkDialog(videoUrlController: videoUrlController, firestore: _firestore, groupId: widget.groupId, box: box, messageController: messageController),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                  shape: const StadiumBorder(),
                                                                                  leading: const Icon(
                                                                                    Icons.link,
                                                                                    color: Colors.orangeAccent,
                                                                                  ),
                                                                                  title: const Text(
                                                                                    'Video Link',
                                                                                    style: TextStyle(
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Flexible(
                                                                                child: ListTile(
                                                                                  onTap: () async {
                                                                                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                                                                                      allowMultiple: false,
                                                                                      allowedExtensions: [
                                                                                        'jpg',
                                                                                        'png',
                                                                                        'gif'
                                                                                      ],
                                                                                      type: FileType.custom,
                                                                                    );

                                                                                    if (result != null) {
                                                                                      // File file = File(result.files.single.path!);
                                                                                      // print(result.files.single.bytes);

                                                                                      // File file = File.fromRawPath(
                                                                                      //   Uint8List.fromList(result.files.single.bytes!),
                                                                                      // );
                                                                                      // String? mimeStr = lookupMimeType(file.);
                                                                                      // var fileType = mimeStr!.split('/');
                                                                                      // print('file type ${fileType}');
                                                                                      Get.dialog(
                                                                                        Center(
                                                                                          child: ImagePostWidget(
                                                                                            groupId: widget.groupId,
                                                                                            result: result,
                                                                                            isDrop: false,
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    } else {
                                                                                      // User canceled the picker
                                                                                    }
                                                                                  },
                                                                                  shape: const StadiumBorder(),
                                                                                  leading: const Icon(
                                                                                    Icons.image,
                                                                                    color: Colors.blueAccent,
                                                                                  ),
                                                                                  title: const Text(
                                                                                    'Image',
                                                                                    style: TextStyle(
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Flexible(
                                                                                child: ListTile(
                                                                                  onTap: () async {
                                                                                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                                                                                      allowMultiple: false,
                                                                                      allowedExtensions: [
                                                                                        'xlsx',
                                                                                        'xls',
                                                                                      ],
                                                                                      type: FileType.custom,
                                                                                    );

                                                                                    if (result != null) {
                                                                                      // File file = File(result.files.single.path!);
                                                                                      // print(result.files.single.bytes);
                                                                                      Get.dialog(
                                                                                        Center(
                                                                                          child: FileSendWidget(
                                                                                            groupId: widget.groupId,
                                                                                            result: result,
                                                                                            isDrop: false,
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    } else {
                                                                                      // User canceled the picker
                                                                                    }
                                                                                  },
                                                                                  shape: const StadiumBorder(),
                                                                                  leading: const Icon(
                                                                                    Icons.file_upload,
                                                                                    color: Colors.yellow,
                                                                                  ),
                                                                                  title: const Text(
                                                                                    'Attach file',
                                                                                    style: TextStyle(
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                    child: Transform
                                                                        .rotate(
                                                                      angle:
                                                                          math.pi /
                                                                              4,
                                                                      child:
                                                                          const Icon(
                                                                        Icons
                                                                            .attach_file,
                                                                        color: Colors
                                                                            .white60,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              // Flexible(
                                                              //   child: Container(),
                                                              // ),
                                                              GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  String
                                                                      messageText =
                                                                      '';
                                                                  if (controller
                                                                          .messageController!
                                                                          .text
                                                                          .isNotEmpty &&
                                                                      controller
                                                                              .messageController!
                                                                              .text
                                                                              .trim() !=
                                                                          '') {
                                                                    messageText =
                                                                        controller
                                                                            .messageController!
                                                                            .text;
                                                                    /*final value = await FlutterClipboard.paste();*/
                                                                    String
                                                                        message =
                                                                        controller
                                                                            .messageController!
                                                                            .text /*+ value.toString()*/;
                                                                    // clear textfield
                                                                    Get.find<
                                                                            AppControllers>()
                                                                        .textFieldClear();
                                                                    if (controller
                                                                        .isMessageEdit) {
                                                                      await _firestore
                                                                          .collection(
                                                                              'groups')
                                                                          .doc(widget
                                                                              .groupId)
                                                                          .collection(
                                                                              'groupMessages')
                                                                          .doc(controller
                                                                              .editMessageId)
                                                                          .update({
                                                                        'message':
                                                                            message,
                                                                      });

                                                                      // Get.find<AppControllers>()
                                                                      //     .setMessageEdit(
                                                                      //         isEdit: false,
                                                                      //         msgId: '');
                                                                    } else if (controller
                                                                        .isMessageReply) {
                                                                      await _firestore
                                                                          .collection(
                                                                              'groups')
                                                                          .doc(widget
                                                                              .groupId)
                                                                          .collection(
                                                                              'groupMessages')
                                                                          .doc()
                                                                          .set({
                                                                        'message':
                                                                            message,
                                                                        'senderId':
                                                                            box.read('id'),
                                                                        'senderImage':
                                                                            null,
                                                                        'senderName':
                                                                            box.read('username'),
                                                                        'senderPhone':
                                                                            box.read('phone'),
                                                                        'type':
                                                                            'reply',
                                                                        'replyId':
                                                                            controller.replymessageId,
                                                                        'groupId':
                                                                            widget.groupId,
                                                                        'new':
                                                                            true,
                                                                        'seenBy':
                                                                            [],
                                                                        'time':
                                                                            DateTime.now(),
                                                                      });
                                                                      await _firestore
                                                                          .collection(
                                                                              'groups')
                                                                          .doc(widget
                                                                              .groupId)
                                                                          .update({
                                                                        'message':
                                                                            message,
                                                                      });
                                                                      Get.find<AppControllers>().setMessageReply(
                                                                          isReply:
                                                                              false,
                                                                          msgId:
                                                                              '',
                                                                          message:
                                                                              '',
                                                                          username:
                                                                              '');
                                                                      Get.find<
                                                                              AppControllers>()
                                                                          .setInputFocus();
                                                                      Get.find<
                                                                              AppControllers>()
                                                                          .setInputFocus();
                                                                      // SendNotif.sendPushMessageToWeb(
                                                                      //     groupId: widget
                                                                      //         .groupId,
                                                                      //     message:
                                                                      //         messageText,
                                                                      //     groupName:
                                                                      //         groupName!);
                                                                    } else {
                                                                      await _firestore
                                                                          .collection(
                                                                              'groups')
                                                                          .doc(widget
                                                                              .groupId)
                                                                          .collection(
                                                                              'groupMessages')
                                                                          .doc()
                                                                          .set({
                                                                        'message':
                                                                            message,
                                                                        'senderId':
                                                                            box.read('id'),
                                                                        'senderImage':
                                                                            null,
                                                                        'senderName':
                                                                            box.read('username'),
                                                                        'senderPhone':
                                                                            box.read('phone'),
                                                                        'new':
                                                                            true,
                                                                        'time':
                                                                            DateTime.now(),
                                                                        'seenBy':
                                                                            [],
                                                                        'type':
                                                                            'text',
                                                                      });
                                                                      await _firestore
                                                                          .collection(
                                                                              'groups')
                                                                          .doc(widget
                                                                              .groupId)
                                                                          .update({
                                                                        'message':
                                                                            message,
                                                                      });
                                                                      Get.find<
                                                                              AppControllers>()
                                                                          .setInputFocus();
                                                                      // SendNotif
                                                                      //     .sendPushMessageToWeb(
                                                                      //   groupId:
                                                                      //       widget.groupId,
                                                                      //   message:
                                                                      //       messageText,
                                                                      //   groupName:
                                                                      //       groupName!,
                                                                      // );
                                                                    }

                                                                    // _scrollController.animateTo(
                                                                    //   0.0,
                                                                    //   curve: Curves.easeOut,
                                                                    //   duration:
                                                                    //       const Duration(milliseconds: 300),
                                                                    // );
                                                                  }
                                                                },
                                                                child:
                                                                    CircleAvatar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  radius: 25.0,
                                                                  child: Icon(
                                                                    Icons.send,
                                                                    color: Palette
                                                                        .mainColor,
                                                                    size: 21.0,
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                              ),
                                            ),
                                          );
                                        }),
                                    Visibility(
                                        visible: isEmojiVisible,
                                        child: EmojiPickerWidget(
                                            onEmojiSelecterd: (String emoji) =>
                                                setState(() {
                                                  controller.messageController!
                                                      .text = controller
                                                          .messageController!
                                                          .text +
                                                      emoji;
                                                }))),
                                  ],
                                ),
                              ),
                              // data!['isOff'] == true
                              //     ? Stack(
                              //         children: [
                              //           Blur(
                              //             blur: 2.5,
                              //             blurColor: Colors.transparent,
                              //             child: Container(
                              //               color: Palette.mainColor
                              //                   .withOpacity(0.4),
                              //             ),
                              //           ),
                              //           Center(
                              //             child: Column(
                              //               mainAxisAlignment:
                              //                   MainAxisAlignment.center,
                              //               children: const [
                              //                 Icon(
                              //                   Icons.lock_outline,
                              //                   size: 50.0,
                              //                   color: Colors.white,
                              //                 ),
                              //                 Text(
                              //                   'Group Closed',
                              //                   style: TextStyle(
                              //                     fontSize: 22.0,
                              //                     color: Colors.white,
                              //                     fontWeight: FontWeight.bold,
                              //                   ),
                              //                 )
                              //               ],
                              //             ),
                              //           )
                              //         ],
                              //       )
                              //     : const SizedBox(),
                              Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        color: highlight
                                            ? Palette.appColor
                                            : Colors.transparent,
                                        child: DottedBorder(
                                          borderType: BorderType.RRect,
                                          color: highlight
                                              ? Colors.white
                                              : Colors.transparent,
                                          strokeWidth: 3,
                                          dashPattern: [8, 4],
                                          radius: const Radius.circular(10),
                                          padding: EdgeInsets.zero,
                                          child: SizedBox(
                                            height: 300,
                                            child: highlight
                                                ? Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: const [
                                                        Icon(
                                                          Icons
                                                              .cloud_upload_outlined,
                                                          size: 80,
                                                          color: Colors.white,
                                                        ),
                                                        Text(
                                                          'Drop Files Here',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 24),
                                                        ),
                                                        SizedBox(
                                                          height: 16,
                                                        ),
                                                        Text(
                                                          'In a quick way',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 20),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      // DroppedFileWidget(file: file),
                                    ],
                                  ))
                            ],
                          );
                        },
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class SendAlertWidget extends StatefulWidget {
  const SendAlertWidget({
    Key? key,
    required this.groupId,
  }) : super(key: key);
  final String groupId;

  @override
  State<SendAlertWidget> createState() => _SendAlertWidgetState();
}

class _SendAlertWidgetState extends State<SendAlertWidget> {
  final box = GetStorage();
  bool isLoading = false;
  final _firestore = FirebaseFirestore.instance;

  //send notification
  sendPushMessageToWeb() async {
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .collection('groupMembers')
        .get()
        .then(
      (value) async {
        for (var item in value.docs) {
          await _firestore
              .collection('users')
              .doc(item.id)
              .get()
              .then((userData) async {
            if (userData.data()!.containsKey('notificationToken')) {
              if (userData['notificationToken'] == null) {
                print('Unable to send FCM message, no token exists.');
                return;
              }
              try {
                await http
                    .post(
                      Uri.parse('https://fcm.googleapis.com/fcm/send'),
                      headers: <String, String>{
                        'Content-Type': 'application/json',
                        'Authorization':
                            'key=AAAAicQOfr8:APA91bEVWSzNZyl0j6pVz7W4qqd7_LKEE9x1LJz21vsBt06IIBz1Iy77CRQzO4u8Nilm0Pl1hV8OFIu-g9ljMsnY25_YJm03umWvWWTTX2aybaiX0MR_HiaDIZEj1MhJRoBhlOC4SN7O'
                      },
                      body: json.encode({
                        "to": userData['notificationToken'],
                        "message": {
                          "token": userData['notificationToken'],
                        },
                        "notification": {
                          "title": "Admin Alert Message",
                          "body": "Admin just sent an alert !"
                        }
                      }),
                    )
                    .then((value) => print(value.body));
                print('FCM request for web sent!');
                Get.back();
              } catch (e) {
                print(e);
              }
            }
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        color: Palette.appColor,
        height: kIsWeb ? 200.h : 26.h,
        width: kIsWeb ? 300.w : 80.w,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Send Alert to users'),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black,
          ),
          backgroundColor: Palette.secondColor,
          body: Container(
            color: Palette.searchTextFieldColor,
            child: const Center(
              child: Text(
                'Send alert to the users of this group !',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
          bottomNavigationBar: Container(
            color: Colors.transparent,
            height: kIsWeb ? 60.h : 60.h,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: FlatButton(
                        color: Colors.white,
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          await sendPushMessageToWeb();
                          await _firestore
                              .collection('groups')
                              .doc(widget.groupId)
                              .collection('groupMessages')
                              .doc()
                              .set({
                            'message': 'Admin alert !',
                            'senderId': box.read('id'),
                            'senderImage': null,
                            'senderName': box.read('username'),
                            'senderPhone': box.read('phone'),
                            'type': 'alert',
                            'groupId': widget.groupId,
                            'new': true,
                            'seenBy': [],
                            'time': DateTime.now(),
                          });
                          setState(() {
                            isLoading = false;
                          });
                        },
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          'Send',
                          style: TextStyle(
                            color: Palette.appColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class SendVideoLinkDialog extends StatelessWidget {
  const SendVideoLinkDialog({
    Key? key,
    required this.videoUrlController,
    required FirebaseFirestore firestore,
    required this.box,
    required this.messageController,
    required this.groupId,
  })  : _firestore = firestore,
        super(key: key);

  final TextEditingController videoUrlController;
  final FirebaseFirestore _firestore;
  final String groupId;
  final GetStorage box;
  final TextEditingController messageController;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: SizedBox(
        width: kIsWeb ? 300.w : 300.w,
        height: 150.h,
        child: Scaffold(
          backgroundColor: Palette.secondColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black,
            title: const Text(
              'Send Video Link',
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  if (videoUrlController.text.isNotEmpty) {
                    await _firestore
                        .collection('groups')
                        .doc(groupId)
                        .collection('groupMessages')
                        .doc()
                        .set({
                      'message': videoUrlController.text,
                      'senderId': box.read('id'),
                      'senderImage': null,
                      'senderName': box.read('username'),
                      'senderPhone': box.read('phone'),
                      'type': 'link',
                      'new': true,
                      'seenBy': [],
                      'time': DateTime.now(),
                    });
                    await _firestore.collection('groups').doc(groupId).update({
                      'message': messageController.text,
                    });
                    messageController.clear();
                    Navigator.pop(context);
                    // _scrollController.animateTo(
                    //   0.0,
                    //   curve: Curves.easeOut,
                    //   duration:
                    //       const Duration(milliseconds: 300),
                    // );
                  }
                },
                icon: const Icon(
                  Icons.send,
                ),
              )
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(
                8.0,
              ),
              child: TextField(
                controller: videoUrlController,
                decoration: InputDecoration(
                    fillColor: Palette.searchTextFieldColor,
                    filled: true,
                    border: InputBorder.none,
                    hintText: 'Share the link',
                    hintStyle: const TextStyle(
                      color: Colors.white70,
                    )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VideoDialog extends StatelessWidget {
  const VideoDialog({
    Key? key,
    required this.chewieController,
  }) : super(key: key);

  final ChewieController chewieController;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: SizedBox(
        width: 30.w,
        height: 40.h,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Palette.appColor,
            title: const Text(
              'Send Video',
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.send,
                ),
              )
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(
                8.0,
              ),
              child: Chewie(
                controller: chewieController,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MessageBubbleWidget extends StatelessWidget {
  const MessageBubbleWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Material(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(0),
            ),
            elevation: 3.0,
            color: Colors.blueAccent,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const <Widget>[
                  Text(
                    'Hi there',
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 5.0,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: Text(
              '2:40 AM',
              style: TextStyle(
                  fontSize: 10.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
