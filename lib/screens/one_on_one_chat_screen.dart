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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';
import 'package:kiranapp/screens/EmojiPickerWidget.dart';
import 'package:kiranapp/screens/widgets/admin_alert_bubble_widget.dart';
import 'package:kiranapp/screens/widgets/image_post_widget.dart';
import 'package:kiranapp/screens/widgets/message_reply_bubble.dart';
import 'package:kiranapp/screens/widgets/video_chat_bubble.dart';
import '../controllers/app_controller.dart';
import '../design/app_colors.dart';
import 'dart:math' as math;
import '../model/chat_message.dart';
import '../services/send_notification.dart';
import 'chat_screen_widget.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/image_chat_bubble.dart';
import 'widgets/link_bubble.dart';
import 'widgets/model/file_DataModel.dart';
import 'widgets/one_chat_bubbles.dart';
import 'widgets/yes_or_no_clear_group_messages.dart';

class OneOnOneChatScreen extends StatefulWidget {
  const OneOnOneChatScreen({
    Key? key,
    required this.groupId,
    required this.userName,
  }) : super(key: key);
  final String groupId;
  final String userName;
  @override
  State<OneOnOneChatScreen> createState() => _OneOnOneChatScreenState();
}

class _OneOnOneChatScreenState extends State<OneOnOneChatScreen> {
  bool _switchValue = false;
  final _firestore = FirebaseFirestore.instance;
  final box = GetStorage();
  final messageController = TextEditingController();
  // final ScrollController _scrollController;
  bool isLoading = false;
  final videoUrlController = TextEditingController();
  AppControllers appcontroller = Get.put(AppControllers());
  var focusNode = FocusNode();

  File_Data_Model? file;

  late DropzoneViewController dropController;
  bool highlight = false;
  ScrollController _scrollController = ScrollController();
  String? otherUserId;

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    await getOtherUserId();
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

  Future getOtherUserId() async {
    final userData = await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .collection('groupMembers')
        .get();
    userData.docs.forEach((x) {
      if (x.id != box.read('id')) {
        setState(() {
          otherUserId = x.id;
        });
      }
    });
    return userData;
  }

  @override
  Widget build(BuildContext context) {
    // appcontroller.clearMessageReply();
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
                        child: const Icon(
                          Icons.person,
                        ),
                      ),
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        widget.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                      FutureBuilder(
                          future: getOtherUserId(),
                          builder: (BuildContext context, s) {
                            if (!s.hasData) {
                              return const SizedBox();
                            }
                            return StreamBuilder(
                                stream: _firestore
                                    .collection('users')
                                    .doc(otherUserId)
                                    .snapshots(),
                                builder: (context,
                                    AsyncSnapshot<
                                            DocumentSnapshot<
                                                Map<String, dynamic>>>
                                        snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox();
                                  }
                                  final user = snapshot.data!.data();
                                  return user!['status'] == 'Online'
                                      ? const SelectableText(
                                          'Online',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 15.0,
                                          ),
                                        )
                                      : SelectableText(
                                          'Last seen ${user['status']}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 15.0,
                                          ),
                                        );
                                });
                          })
                    ],
                  ),
                  actions: [
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
                                child: CupertinoSwitch(
                                  activeColor: Palette.appColor,
                                  value: data!['isOff'],
                                  onChanged: (value) async {
                                    // setState(() {
                                    //   _switchValue = value;
                                    // });
                                    await _firestore
                                        .collection('groups')
                                        .doc(widget.groupId)
                                        .update({
                                      'isOff': value,
                                    });
                                  },
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
                    box.read('isAdmin')!
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
                                  height: 100.h,
                                  width: 230.w,
                                  child: Column(
                                    children: [
                                      Flexible(
                                        child: ListTile(
                                          onTap: () async {
                                            Get.dialog(
                                              Center(
                                                child:
                                                    YesOrNoClearGroupMessagesWidget(
                                                  groupId: widget.groupId,
                                                  isOneChat: true,
                                                ),
                                              ),
                                            );
                                          },
                                          shape: const StadiumBorder(),
                                          leading: const Icon(
                                            Icons.clear,
                                            color: Colors.white,
                                          ),
                                          title: const Text(
                                            'Clear Chat',
                                            style: TextStyle(
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
                                          title: const Text(
                                            'Delete Chat',
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
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.more_vert,
                                color: Colors.white60,
                              ),
                            ),
                          )
                        : const SizedBox(),
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
                                            // print(doc["message"]);
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

                                          chatMessage =
                                              chatMessage.reversed.toList();
                                          return chatMessage.isEmpty
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Icon(
                                                      Icons.chat_bubble,
                                                      size: 80.0,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      'Chat Empty',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 25.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )
                                                  ],
                                                )
                                              : Scrollbar(
                                                  controller: _scrollController,
                                                  child: ListView.builder(
                                                    controller:
                                                        _scrollController,
                                                    itemCount:
                                                        chatMessage.length,
                                                    shrinkWrap: true,
                                                    reverse: true,
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 10,
                                                      bottom: 10,
                                                    ),
                                                    physics:
                                                        const ScrollPhysics(),
                                                    itemBuilder:
                                                        (context, index) {
                                                      // ignore: unrelated_type_equality_checks
                                                      return chatMessage[index]
                                                                  .messageType ==
                                                              'time'
                                                          ? Center(
                                                              child: Container(
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                  vertical:
                                                                      10.h,
                                                                ),
                                                                child: SizedBox(
                                                                  height: 35.h,
                                                                  width: 70.w,
                                                                  child:
                                                                      Material(
                                                                    color: Colors
                                                                            .yellow[
                                                                        100],
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        chatMessage[index]
                                                                            .message,
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.yellow[900],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : chatMessage[index]
                                                                      .messageType ==
                                                                  'text'
                                                              ? OneChatBubble(
                                                                  chatMessage:
                                                                      chatMessage[
                                                                          index],
                                                                  groupId: widget
                                                                      .groupId,
                                                                )
                                                              : chatMessage[index]
                                                                          .messageType ==
                                                                      'alert'
                                                                  ? AdminAlertBubbleWidget(
                                                                      chatMessage:
                                                                          chatMessage[
                                                                              index],
                                                                      groupId:
                                                                          widget
                                                                              .groupId,
                                                                    )
                                                                  : chatMessage[index]
                                                                              .messageType ==
                                                                          'image'
                                                                      ? ImageChatBubble(
                                                                          chatMessage:
                                                                              chatMessage[index],
                                                                          groupId:
                                                                              widget.groupId,
                                                                        )
                                                                      : chatMessage[index].messageType ==
                                                                              'link'
                                                                          ? LinkBubble(
                                                                              chatMessage: chatMessage[index],
                                                                              groupId: widget.groupId,
                                                                            )
                                                                          : chatMessage[index].messageType == 'reply'
                                                                              ? MessageReplyBubble(
                                                                                  text: chatMessage[index].data["message"],
                                                                                  isMe: chatMessage[index].data["senderId"] == box.read('id') ? true : false,
                                                                                  time: chatMessage[index].data["time"],
                                                                                  documentID: chatMessage[index].msgId,
                                                                                  isStarred: false,
                                                                                  replyId: chatMessage[index].data["replyId"],
                                                                                  groupId: widget.groupId,
                                                                                  senderId: chatMessage[index].data["senderId"],
                                                                                  username: chatMessage[index].userName,
                                                                                  chatMessage: chatMessage[index],
                                                                                )
                                                                              : VideoChatBubble(
                                                                                  chatMessage: chatMessage[index],
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
                                                  Text(
                                                    controller.isMessageEdit
                                                        ? 'Editing Message'
                                                        : 'Message Reply to ${controller.replyUsername}: ${controller.replymessage}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                                    width:
                                                                        0.5.w,
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
                                                              // ),.
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

                                                                            Get.find<AppControllers>().setInputFocus();
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

                                                                    if (event.isKeyPressed(LogicalKeyboardKey
                                                                            .enter) &&
                                                                        event
                                                                            .isShiftPressed) {}
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
                                                              // Flexible(
                                                              //   flex: 5,
                                                              //   child:
                                                              //
                                                              //   //     TextField(
                                                              //   //
                                                              //   //   autofocus:
                                                              //   //       true,
                                                              //   //   controller:
                                                              //   //       controller
                                                              //   //           .messageController,
                                                              //   //   readOnly: data!['isOff'] ==
                                                              //   //               true &&
                                                              //   //           box.read('isAdmin') !=
                                                              //   //               true
                                                              //   //       ? true
                                                              //   //       : false,
                                                              //   //   focusNode:
                                                              //   //       controller
                                                              //   //           .focusNode,
                                                              //   //   onSubmitted:
                                                              //   //       (value) async {
                                                              //   //     String
                                                              //   //         messageText =
                                                              //   //         '';
                                                              //   //     if (controller
                                                              //   //             .messageController!
                                                              //   //             .text
                                                              //   //             .isNotEmpty &&
                                                              //   //         controller.messageController!.text.trim() !=
                                                              //   //             '') {
                                                              //   //       messageText = controller
                                                              //   //           .messageController!
                                                              //   //           .text;
                                                              //   //       String
                                                              //   //           message =
                                                              //   //           controller
                                                              //   //               .messageController!
                                                              //   //               .text;
                                                              //   //       // clear textfield
                                                              //   //       Get.find<
                                                              //   //               AppControllers>()
                                                              //   //           .setTextFieldController(
                                                              //   //               text: '');
                                                              //   //
                                                              //   //       if (controller
                                                              //   //           .isMessageEdit) {
                                                              //   //         await _firestore
                                                              //   //             .collection('groups')
                                                              //   //             .doc(widget.groupId)
                                                              //   //             .collection('groupMessages')
                                                              //   //             .doc(controller.editMessageId)
                                                              //   //             .update({
                                                              //   //           'message':
                                                              //   //               message,
                                                              //   //         });
                                                              //   //
                                                              //   //         // Get.find<
                                                              //   //         //         AppControllers>()
                                                              //   //         //     .textFieldClear();
                                                              //   //         Get.find<AppControllers>().setMessageEdit(
                                                              //   //             isEdit:
                                                              //   //                 false,
                                                              //   //             msgId:
                                                              //   //                 '');
                                                              //   //       } else if (controller
                                                              //   //           .isMessageReply) {
                                                              //   //         await _firestore
                                                              //   //             .collection('groups')
                                                              //   //             .doc(widget.groupId)
                                                              //   //             .collection('groupMessages')
                                                              //   //             .doc()
                                                              //   //             .set({
                                                              //   //           'message':
                                                              //   //               message,
                                                              //   //           'senderId':
                                                              //   //               box.read('id'),
                                                              //   //           'senderImage':
                                                              //   //               null,
                                                              //   //           'senderName':
                                                              //   //               box.read('username'),
                                                              //   //           'senderPhone':
                                                              //   //               box.read('phone'),
                                                              //   //           'type':
                                                              //   //               'reply',
                                                              //   //           'replyId':
                                                              //   //               controller.replymessageId,
                                                              //   //           'groupId':
                                                              //   //               widget.groupId,
                                                              //   //           'new':
                                                              //   //               true,
                                                              //   //           'seenBy':
                                                              //   //               [],
                                                              //   //           'time':
                                                              //   //               DateTime.now().add(
                                                              //   //             const Duration(seconds: 1),
                                                              //   //           ),
                                                              //   //           'messageIndex':
                                                              //   //               groupData!['messageIndex'] + 1,
                                                              //   //         });
                                                              //   //         await _firestore
                                                              //   //             .collection('groups')
                                                              //   //             .doc(widget.groupId)
                                                              //   //             .update({
                                                              //   //           'message':
                                                              //   //               message,
                                                              //   //           'messageIndex':
                                                              //   //               groupData['messageIndex'] + 1,
                                                              //   //         });
                                                              //   //         Get.find<AppControllers>().setMessageReply(
                                                              //   //             isReply:
                                                              //   //                 false,
                                                              //   //             msgId:
                                                              //   //                 '',
                                                              //   //             message:
                                                              //   //                 '',
                                                              //   //             username:
                                                              //   //                 '');
                                                              //   //         // SendNotif
                                                              //   //         //     .sendPushMessageToWeb(
                                                              //   //         //   groupId:
                                                              //   //         //       widget.groupId,
                                                              //   //         //   message:
                                                              //   //         //       messageText,
                                                              //   //         //   groupName:
                                                              //   //         //       box.read('username')!,
                                                              //   //         // );
                                                              //   //         // Get.find<
                                                              //   //         //         AppControllers>()
                                                              //   //         //     .textFieldClear();
                                                              //   //       } else {
                                                              //   //         await _firestore
                                                              //   //             .collection('groups')
                                                              //   //             .doc(widget.groupId)
                                                              //   //             .collection('groupMessages')
                                                              //   //             .doc()
                                                              //   //             .set({
                                                              //   //           'message':
                                                              //   //               message,
                                                              //   //           'senderId':
                                                              //   //               box.read('id'),
                                                              //   //           'senderImage':
                                                              //   //               null,
                                                              //   //           'senderName':
                                                              //   //               box.read('username'),
                                                              //   //           'senderPhone':
                                                              //   //               box.read('phone'),
                                                              //   //           'type':
                                                              //   //               'text',
                                                              //   //           'new':
                                                              //   //               true,
                                                              //   //           'seenBy':
                                                              //   //               [],
                                                              //   //           'time':
                                                              //   //               DateTime.now().add(
                                                              //   //             const Duration(seconds: 1),
                                                              //   //           ),
                                                              //   //           'messageIndex':
                                                              //   //               groupData!['messageIndex'] + 1,
                                                              //   //         });
                                                              //   //         await _firestore
                                                              //   //             .collection('groups')
                                                              //   //             .doc(widget.groupId)
                                                              //   //             .update({
                                                              //   //           'message':
                                                              //   //               message,
                                                              //   //           'messageIndex':
                                                              //   //               groupData['messageIndex'] + 1,
                                                              //   //         });
                                                              //   //
                                                              //   //         // SendNotif
                                                              //   //         //     .sendPushMessageToWeb(
                                                              //   //         //   groupId:
                                                              //   //         //       widget.groupId,
                                                              //   //         //   message:
                                                              //   //         //       messageText,
                                                              //   //         //   groupName:
                                                              //   //         //       box.read('username')!,
                                                              //   //         // );
                                                              //   //       }
                                                              //   //       Get.find<
                                                              //   //               AppControllers>()
                                                              //   //           .setInputFocus();
                                                              //   //       // _scrollController.animateTo(
                                                              //   //       //   0.0,
                                                              //   //       //   curve: Curves.easeOut,
                                                              //   //       //   duration:
                                                              //   //       //       const Duration(milliseconds: 300),
                                                              //   //       // );
                                                              //   //     }
                                                              //   //   },
                                                              //   //   maxLines: null,
                                                              //   //   style: const TextStyle(
                                                              //   //       color: Colors
                                                              //   //           .white),
                                                              //   //   decoration:
                                                              //   //       InputDecoration(
                                                              //   //     hintText:
                                                              //   //         'Type message...',
                                                              //   //     hintStyle:
                                                              //   //         const TextStyle(
                                                              //   //       color: Colors
                                                              //   //           .white60,
                                                              //   //       fontWeight:
                                                              //   //           FontWeight
                                                              //   //               .w100,
                                                              //   //       fontSize:
                                                              //   //           17,
                                                              //   //     ),
                                                              //   //     // filled: true,
                                                              //   //     // fillColor:
                                                              //   //     //     Palette.searchTextFieldColor,
                                                              //   //     border:
                                                              //   //         OutlineInputBorder(
                                                              //   //       borderRadius:
                                                              //   //           BorderRadius.circular(
                                                              //   //               20),
                                                              //   //     ),
                                                              //   //     enabledBorder:
                                                              //   //         OutlineInputBorder(
                                                              //   //       borderSide:
                                                              //   //           const BorderSide(
                                                              //   //         color: Colors
                                                              //   //             .transparent,
                                                              //   //         width:
                                                              //   //             0.0,
                                                              //   //       ),
                                                              //   //       borderRadius:
                                                              //   //           BorderRadius.circular(
                                                              //   //               20),
                                                              //   //     ),
                                                              //   //     focusedBorder:
                                                              //   //         OutlineInputBorder(
                                                              //   //       borderSide:
                                                              //   //           const BorderSide(
                                                              //   //         color: Colors
                                                              //   //             .transparent,
                                                              //   //         width:
                                                              //   //             0.0,
                                                              //   //       ),
                                                              //   //       borderRadius:
                                                              //   //           BorderRadius.circular(
                                                              //   //               20),
                                                              //   //     ),
                                                              //   //   ),
                                                              //   // ),
                                                              // ),
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
                                                                            false, // DISABLED THIS ITEM
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
                                                                              100.h,
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
                                                                                    FilePickerResult? result = await FilePicker.platform.pickFiles();

                                                                                    if (result != null) {
                                                                                      // File file = File(result.files.single.path!);
                                                                                      // print(result.files.single.bytes);
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
                                                                              // Flexible(
                                                                              //   child: ListTile(
                                                                              //     onTap: () {},
                                                                              //     shape: const StadiumBorder(),
                                                                              //     leading: const Icon(
                                                                              //       Icons.headphones,
                                                                              //       color: Colors.yellow,
                                                                              //     ),
                                                                              //     title: const Text(
                                                                              //       'Audio',
                                                                              //       style: TextStyle(
                                                                              //         color: Colors.white,
                                                                              //       ),
                                                                              //     ),
                                                                              //   ),
                                                                              // ),
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
                                                                    String
                                                                        message =
                                                                        controller
                                                                            .messageController!
                                                                            .text;
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
                                                                            DateTime.now().add(
                                                                          const Duration(
                                                                            seconds:
                                                                                5,
                                                                          ),
                                                                        ),
                                                                        'messageIndex':
                                                                            groupData!['messageIndex'] +
                                                                                1,
                                                                      });
                                                                      await _firestore
                                                                          .collection(
                                                                              'groups')
                                                                          .doc(widget
                                                                              .groupId)
                                                                          .update({
                                                                        'message':
                                                                            message,
                                                                        'messageIndex':
                                                                            groupData['messageIndex'] +
                                                                                1,
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
                                                                      // SendNotif.sendPushMessageToWeb(
                                                                      //     groupId: widget
                                                                      //         .groupId,
                                                                      //     message:
                                                                      //         messageText,
                                                                      //     groupName:
                                                                      //         box.read('username')!);
                                                                      Get.find<
                                                                              AppControllers>()
                                                                          .setInputFocus();
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
                                                                        'seenBy':
                                                                            [],
                                                                        'time':
                                                                            DateTime.now().add(
                                                                          const Duration(
                                                                            seconds:
                                                                                5,
                                                                          ),
                                                                        ),
                                                                        'type':
                                                                            'text',
                                                                        'messageIndex':
                                                                            groupData!['messageIndex'] +
                                                                                1,
                                                                      });
                                                                      await _firestore
                                                                          .collection(
                                                                              'groups')
                                                                          .doc(widget
                                                                              .groupId)
                                                                          .update({
                                                                        'message':
                                                                            message,
                                                                        'messageIndex':
                                                                            groupData['messageIndex'] +
                                                                                1,
                                                                      });

                                                                      // SendNotif
                                                                      //     .sendPushMessageToWeb(
                                                                      //   groupId:
                                                                      //       widget.groupId,
                                                                      //   message:
                                                                      //       messageText,
                                                                      //   groupName:
                                                                      //       box.read('username')!,
                                                                      // );
                                                                    }
                                                                    FocusScope.of(
                                                                            context)
                                                                        .requestFocus(
                                                                      focusNode,
                                                                    );
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

class YesOrNoWidget extends StatefulWidget {
  const YesOrNoWidget({
    Key? key,
    required this.groupId,
  }) : super(key: key);
  final String groupId;
  @override
  State<YesOrNoWidget> createState() => _YesOrNoWidgetState();
}

class _YesOrNoWidgetState extends State<YesOrNoWidget> {
  final box = GetStorage();
  bool isLoading = false;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        color: Palette.appColor,
        height: 200.h,
        width: 300.0.w,
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(
              Icons.delete,
            ),
            title: const Text(
              'Delete Chat',
            ),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black,
          ),
          backgroundColor: Palette.secondColor,
          body: Container(
            color: Palette.searchTextFieldColor,
            child: Column(
              children: [
                SizedBox(
                  height: 13.h,
                ),
                const Text(
                  'Are sure you want to delete this chat ?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15.0,
                  ),
                ),
                SizedBox(
                  height: 13.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ButtonTheme(
                      minWidth: 100.w,
                      height: 60.h,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: FlatButton(
                                color: Palette.appColor,
                                onPressed: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await _firestore
                                      .collection('groups')
                                      .doc(widget.groupId)
                                      .delete();

                                  await _firestore
                                      .collection('groups')
                                      .doc(widget.groupId)
                                      .collection('groupMembers')
                                      .get()
                                      .then(
                                    (value) async {
                                      for (var item in value.docs) {
                                        await _firestore
                                            .collection('groupChats')
                                            .doc(
                                              item.id,
                                            )
                                            .collection('myGroups')
                                            .doc(widget.groupId)
                                            .delete();
                                      }
                                    },
                                  );
                                  Get.snackbar(
                                    'Message',
                                    'Chat successfully deleted!',
                                    maxWidth: 300.w,
                                    colorText: Colors.white,
                                  );
                                  setState(() {
                                    isLoading = false;
                                  });
                                  Navigator.pop(context);
                                },
                                padding: const EdgeInsets.all(5),
                                child: const Text(
                                  'Yes',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    SizedBox(
                      width: 13.w,
                    ),
                    ButtonTheme(
                      minWidth: 100.w,
                      height: 60.h,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                        // ignore: deprecated_member_use
                        child: FlatButton(
                          color: Colors.grey[300],
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          padding: const EdgeInsets.all(5),
                          child: const Text(
                            'No',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
