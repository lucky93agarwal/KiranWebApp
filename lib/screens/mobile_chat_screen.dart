// ignore_for_file: deprecated_member_use
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:kiranapp/screens/widgets/add_people_dialog.dart';
import 'package:kiranapp/screens/widgets/admin_alert_bubble_widget.dart';
import 'package:kiranapp/screens/widgets/group_users.dart';
import 'package:kiranapp/screens/widgets/image_post_widget.dart';
import 'package:kiranapp/screens/widgets/message_reply_bubble.dart';
import 'package:kiranapp/screens/widgets/remove_people_dialog.dart';
import 'package:kiranapp/screens/widgets/transfer_users.dart';
import 'package:kiranapp/screens/widgets/video_chat_bubble.dart';
import 'package:kiranapp/screens/widgets/yes_or_no.dart';
import '../controllers/app_controller.dart';
import '../design/app_colors.dart';
import 'dart:math' as math;
import '../model/chat_message.dart';

import 'chat_screen_widget.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/export_data_widget.dart';
import 'widgets/image_chat_bubble.dart';
import 'widgets/link_bubble.dart';
import 'widgets/model/file_DataModel.dart';

class MobileChatScreen extends StatefulWidget {
  const MobileChatScreen({Key? key, required this.groupId}) : super(key: key);

  final String groupId;
  @override
  State<MobileChatScreen> createState() => _MobileChatScreenState();
}

class _MobileChatScreenState extends State<MobileChatScreen> {
  bool _switchValue = false;
  final _firestore = FirebaseFirestore.instance;
  final box = GetStorage();
  final messageController = TextEditingController();
  // final ScrollController _scrollController;
  bool isLoading = false;
  final videoUrlController = TextEditingController();
  AppControllers appcontroller = Get.put(AppControllers());
  late ScrollController _scrollController;
  var focusNode = FocusNode();

  File_Data_Model? file;

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
    return Scaffold(
      body: Container(
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
                  toolbarHeight: 6.5.h,
                  backgroundColor: Palette.secondColor,
                  // leading: const IconButton(
                  //   onPressed: null,
                  //   icon: Icon(
                  //     Icons.arrow_back,
                  //   ),
                  // ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // CircleAvatar(
                      //   backgroundColor: Colors.white,
                      //   radius: 23.0,
                      //   child: CircleAvatar(
                      //     backgroundColor: Palette.appColor,
                      //     radius: 23.0,
                      //     child: data['type'] == 'group'
                      //         ? const Icon(
                      //             Icons.groups,
                      //           )
                      //         : const Icon(
                      //             Icons.announcement,
                      //           ),
                      //   ),
                      // ),
                      Flexible(
                        child: SelectableText(
                          data['groupName'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
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
                                  height: 28.h,
                                  width: 70.w,
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
                                                  height: 40.h,
                                                  width: 80.w,
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
                                                          onTap: () {},
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
                                                child: TransferUsers(
                                                  groupId: widget.groupId,
                                                ),
                                              ),
                                            );
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
                    return GetBuilder<AppControllers>(
                      builder: (controller) {
                        return Stack(
                          children: [
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
                                            descending: true,
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

                                        for (var doc in snapshot.data!.docs) {
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
                                        return ListView.builder(
                                          itemCount: chatMessage.length,
                                          shrinkWrap: true,
                                          reverse: true,
                                          padding: const EdgeInsets.only(
                                            top: 10,
                                            bottom: 10,
                                          ),
                                          physics: const ScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            // ignore: unrelated_type_equality_checks
                                            return chatMessage[index]
                                                        .messageType ==
                                                    'text'
                                                ? ChatBubble(
                                                    chatMessage:
                                                        chatMessage[index],
                                                    groupId: widget.groupId,
                                                  )
                                                : chatMessage[index]
                                                            .messageType ==
                                                        'alert'
                                                    ? AdminAlertBubbleWidget(
                                                        chatMessage:
                                                            chatMessage[index],
                                                            groupId: widget.groupId,
                                                      )
                                                    : chatMessage[index]
                                                                .messageType ==
                                                            'image'
                                                        ? ImageChatBubble(
                                                            chatMessage:
                                                                chatMessage[
                                                                    index],
                                                            groupId:
                                                                widget.groupId,
                                                          )
                                                        : chatMessage[index]
                                                                    .messageType ==
                                                                'link'
                                                            ? LinkBubble(
                                                                chatMessage:
                                                                    chatMessage[
                                                                        index],
                                                                groupId: widget
                                                                    .groupId,
                                                              )
                                                            : chatMessage[index]
                                                                        .messageType ==
                                                                    'reply'
                                                                ? MessageReplyBubble(
                                                                    text: chatMessage[index]
                                                                            .data[
                                                                        "message"],
                                                                    isMe: chatMessage[index].data["senderId"] ==
                                                                            box.read('id')
                                                                        ? true
                                                                        : false,
                                                                    time: chatMessage[index]
                                                                            .data[
                                                                        "time"],
                                                                    documentID:
                                                                        chatMessage[index]
                                                                            .msgId,
                                                                    isStarred:
                                                                        false,
                                                                    replyId: chatMessage[index]
                                                                            .data[
                                                                        "replyId"],
                                                                    groupId: widget
                                                                        .groupId,
                                                                    senderId: chatMessage[index]
                                                                            .data[
                                                                        "senderId"],
                                                                    username: chatMessage[
                                                                            index]
                                                                        .userName,
                                                                    chatMessage:
                                                                        chatMessage[
                                                                            index],
                                                                  )
                                                                : VideoChatBubble(
                                                                    chatMessage:
                                                                        chatMessage[
                                                                            index],
                                                                  );
                                          },
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
                                            height: 7.h,
                                            width: 90.w,
                                            child: Row(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    if (controller
                                                        .isMessageEdit) {
                                                      Get.find<AppControllers>()
                                                          .textFieldClear();
                                                      Get.find<AppControllers>()
                                                          .setMessageEdit(
                                                              isEdit: false,
                                                              msgId: '');
                                                    } else {
                                                      Get.find<AppControllers>()
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
                                                    fontWeight: FontWeight.bold,
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
                                        final groupData = snapshot.data!.data();
                                        return Container(
                                          height: 9.h,
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6.0,
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
                                                  box.read('isAdmin') != true &&
                                                          groupData!['type'] ==
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
                                                                  width: 0.5.w,
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
                                                              flex: 6,
                                                              child: TextField(
                                                                controller:
                                                                    controller
                                                                        .messageController,
                                                                readOnly: data!['isOff'] ==
                                                                            true &&
                                                                        box.read('isAdmin') !=
                                                                            true
                                                                    ? true
                                                                    : false,
                                                                focusNode:
                                                                    focusNode,
                                                                onSubmitted:
                                                                    (value) async {
                                                                  if (controller
                                                                          .messageController!
                                                                          .text
                                                                          .isNotEmpty &&
                                                                      controller
                                                                              .messageController!
                                                                              .text
                                                                              .trim() !=
                                                                          '') {
                                                                    String
                                                                        message =
                                                                        controller
                                                                            .messageController!
                                                                            .text;
                                                                    // clear textfield
                                                                    Get.find<
                                                                            AppControllers>()
                                                                        .setTextFieldController(
                                                                            text:
                                                                                '');

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

                                                                      // Get.find<
                                                                      //         AppControllers>()
                                                                      //     .textFieldClear();
                                                                      Get.find<AppControllers>().setMessageEdit(
                                                                          isEdit:
                                                                              false,
                                                                          msgId:
                                                                              '');
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
                                                                      // Get.find<
                                                                      //         AppControllers>()
                                                                      //     .textFieldClear();
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
                                                                        'type':
                                                                            'text',
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
                                                                    }
                                                                    FocusScope.of(
                                                                            context)
                                                                        .requestFocus(
                                                                            focusNode);
                                                                    // _scrollController.animateTo(
                                                                    //   0.0,
                                                                    //   curve: Curves.easeOut,
                                                                    //   duration:
                                                                    //       const Duration(milliseconds: 300),
                                                                    // );
                                                                  }
                                                                },
                                                                // maxLines: null,
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                                decoration:
                                                                    InputDecoration(
                                                                  hintText:
                                                                      'Type message...',
                                                                  hintStyle:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .white60,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w100,
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                  // filled: true,
                                                                  // fillColor:
                                                                  //     Palette.searchTextFieldColor,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        const BorderSide(
                                                                      color: Colors
                                                                          .transparent,
                                                                      width:
                                                                          0.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        const BorderSide(
                                                                      color: Colors
                                                                          .transparent,
                                                                      width:
                                                                          0.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Flexible(
                                                              child: Container(
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
                                                                        blur: 5,
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
                                                                          end: Alignment
                                                                              .bottomRight,
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
                                                                          end: Alignment
                                                                              .bottomRight,
                                                                          colors: [
                                                                            //for border..........................................................
                                                                            const Color(0xFF1b242b).withOpacity(0.5),
                                                                            const Color((0xFF1b242b)).withOpacity(0.5),
                                                                          ],
                                                                        ),
                                                                        height:
                                                                            15.h,
                                                                        width:
                                                                            50.w,
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Flexible(
                                                                              child: ListTile(
                                                                                onTap: () async {
                                                                                  Get.bottomSheet(
                                                                                    SendVideoLinkDialog(videoUrlController: videoUrlController, firestore: _firestore, groupId: widget.groupId, box: box, messageController: messageController),
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
                                                              onTap: () async {
                                                                if (controller
                                                                        .messageController!
                                                                        .text
                                                                        .isNotEmpty &&
                                                                    controller
                                                                            .messageController!
                                                                            .text
                                                                            .trim() !=
                                                                        '') {
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
                                                                          box.read(
                                                                              'id'),
                                                                      'senderImage':
                                                                          null,
                                                                      'senderName':
                                                                          box.read(
                                                                              'username'),
                                                                      'senderPhone':
                                                                          box.read(
                                                                              'phone'),
                                                                      'type':
                                                                          'reply',
                                                                      'replyId':
                                                                          controller
                                                                              .replymessageId,
                                                                      'groupId':
                                                                          widget
                                                                              .groupId,
                                                                      'new':
                                                                          true,
                                                                      'seenBy':
                                                                          [],
                                                                      'time': DateTime
                                                                          .now(),
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
                                                                          box.read(
                                                                              'id'),
                                                                      'senderImage':
                                                                          null,
                                                                      'senderName':
                                                                          box.read(
                                                                              'username'),
                                                                      'senderPhone':
                                                                          box.read(
                                                                              'phone'),
                                                                      'new':
                                                                          true,
                                                                      'seenBy':
                                                                          [],
                                                                      'time': DateTime
                                                                          .now(),
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
                                      })
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
                                                            color: Colors.white,
                                                            fontSize: 24),
                                                      ),
                                                      SizedBox(
                                                        height: 16,
                                                      ),
                                                      Text(
                                                        'In a quick way',
                                                        style: TextStyle(
                                                            color: Colors.white,
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
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
