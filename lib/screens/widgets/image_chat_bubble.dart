import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../controllers/app_controller.dart';
import '../../design/app_colors.dart';
import '../../model/chat_message.dart';
import '../chat_screen_widget.dart';
import 'dart:html' as html;

class ImageChatBubble extends StatefulWidget {
  ChatMessage chatMessage;
  ImageChatBubble({required this.chatMessage, required this.groupId});
  final String groupId;
  @override
  _ImageChatBubbleState createState() => _ImageChatBubbleState();
}

class _ImageChatBubbleState extends State<ImageChatBubble> {
  final box = GetStorage();
  final _firestore = FirebaseFirestore.instance;

   //download file
  void downloadFile(String url) {
    // ignore: unnecessary_new
    html.AnchorElement anchorElement = new html.AnchorElement(href: url);
    anchorElement.download = url;
    anchorElement.click();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 16, top: 10, bottom: 10),
      child: VisibilityDetector(
        key: Key(widget.chatMessage.data.id),
        onVisibilityChanged: (visibilityInfo) {
          var visiblePercentage = visibilityInfo.visibleFraction * 100;
          if (visiblePercentage == 100) {
            _firestore
                .collection('groups')
                .doc(widget.groupId)
                .collection('groupMessages')
                .doc(widget.chatMessage.data.id)
                .update({
              'seenBy': FieldValue.arrayUnion(
                [
                  box.read('id'),
                ],
              ),
            });
          }
          // debugPrint(
          //     'Widget ${visibilityInfo.key} is ${visiblePercentage}% visible');
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: (widget.chatMessage.type == MessageType.Receiver
              ? MainAxisAlignment.start
              : MainAxisAlignment.end),
          children: [
            // widget.chatMessage.cat == Category.Group
            //     ? widget.chatMessage.type == MessageType.Receiver
            //         ? StreamBuilder(
            //             stream: FirebaseFirestore.instance
            //                 .collection('users')
            //                 .doc(widget.chatMessage.id)
            //                 .snapshots(),
            //             builder: (context,
            //                 AsyncSnapshot<
            //                         DocumentSnapshot<Map<String, dynamic>>>
            //                     snapshot) {
            //               if (!snapshot.hasData) {
            //                 return const SizedBox();
            //               }
            //               final data = snapshot.data!.data();
            //               return CircleAvatar(
            //                 radius: 12,
            //                 backgroundImage: NetworkImage(data!['url']),
            //               );
            //             })
            //         : const SizedBox()
            //     : const SizedBox(),
            // widget.chatMessage.cat == Category.Group
            //     ? SizedBox(
            //         width: 2.w,
            //       )
            //     : const SizedBox(),
            PopupMenuButton<String>(
              color: Colors.transparent,
              elevation: 0.0,
              tooltip: '',
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem(
                  enabled: false, // DISABLED THIS ITEM
                  child: Container(
                    // padding: const EdgeInsets.all(40),
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.black,
                    ),
                    height: kIsWeb
                        ? box.read('isAdmin')
                            ? widget.chatMessage.type == MessageType.Receiver
                                ? 200.h
                                : 250.h
                            : widget.chatMessage.type == MessageType.Receiver
                                ? 200.h
                                : 250.h
                        : 250.h,
                    width: kIsWeb ? 230.w : 230.w,
                    child: Column(
                      children: [
                        Flexible(
                          child: ListTile(
                            onTap: () {
                              Get.dialog(
                                Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: SizedBox(
                                      width: kIsWeb ? 500.w : 500.w,
                                      height: 500.h,
                                      child: Scaffold(
                                        appBar: AppBar(
                                          automaticallyImplyLeading: false,
                                          backgroundColor: Palette.appColor,
                                          title: const Text(
                                            'Image View',
                                          ),
                                        ),
                                        body: InteractiveViewer(
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                child: Image.network(widget
                                                    .chatMessage.imageUrl),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            shape: const StadiumBorder(),
                            leading: const Icon(
                              Icons.open_in_new,
                              color: Colors.white,
                            ),
                            title: const Text(
                              'Open',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: ListTile(
                            onTap: () {
                              Get.find<AppControllers>().setMessageReply(
                                isReply: true,
                                msgId: widget.chatMessage.msgId,
                                message: widget.chatMessage.message,
                                username: widget.chatMessage.userName,
                              );
                              Navigator.pop(context);
                            },
                            shape: const StadiumBorder(),
                            leading:
                                const Icon(Icons.reply, color: Colors.white),
                            title: const Text(
                              'Reply',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                         Flexible(
                          child: ListTile(
                            onTap: () {
                              downloadFile(widget.chatMessage.imageUrl);
                              Navigator.pop(context);
                            },
                            shape: const StadiumBorder(),
                            leading:
                                const Icon(Icons.download, color: Colors.white),
                            title: const Text(
                              'Download',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: ListTile(
                            onTap: () {},
                            shape: const StadiumBorder(),
                            leading: const Icon(
                              Icons.forward,
                              color: Colors.white,
                            ),
                            title: const Text(
                              'Forward',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        widget.chatMessage.type == MessageType.Receiver
                            ? const SizedBox()
                            : Flexible(
                                child: ListTile(
                                  onTap: () async {
                                    await _firestore
                                        .collection('groups')
                                        .doc(widget.chatMessage.groupId)
                                        .collection('groupMessages')
                                        .doc(widget.chatMessage.msgId)
                                        .delete();
                                    Navigator.pop(context);
                                  },
                                  shape: const StadiumBorder(),
                                  leading: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                  ),
                                  title: const Text(
                                    'Delete',
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
              child: Column(
                crossAxisAlignment:
                    (widget.chatMessage.type == MessageType.Receiver
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end),
                children: [
                  Container(
                    height: 150.h,
                    width: kIsWeb ? 200.w : 200.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft:
                              widget.chatMessage.type == MessageType.Receiver
                                  ? const Radius.circular(0)
                                  : const Radius.circular(30),
                          topLeft: const Radius.circular(30),
                          topRight: const Radius.circular(30),
                          bottomRight:
                              widget.chatMessage.type == MessageType.Receiver
                                  ? const Radius.circular(30)
                                  : const Radius.circular(0)),
                      color: (widget.chatMessage.type == MessageType.Receiver
                          ? Colors.white
                          : Colors.blueAccent),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          widget.chatMessage.imageUrl,
                          cacheWidth: 160,
                          cacheHeight: 220,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Padding(
                    padding: widget.chatMessage.id == box.read('id')
                        ? const EdgeInsets.only(right: 12.0)
                        : const EdgeInsets.only(left: 12.0),
                    child: Row(
                      mainAxisAlignment: widget.chatMessage.id == box.read('id')
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat.jm()
                              .format(widget.chatMessage.time.toDate()),
                          style: const TextStyle(
                              fontSize: 10.0,
                              color: Colors.white60,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 0.5.w,
                        ),
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.chatMessage.id)
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<
                                      DocumentSnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox();
                            }
                            final data = snapshot.data!.data();
                            return Padding(
                              padding: widget.chatMessage.id != box.read('id')
                                  ? const EdgeInsets.only(right: 12.0)
                                  : const EdgeInsets.only(left: 12.0),
                              child: widget.chatMessage.id == box.read('id')
                                  ? const Text(
                                      'Me',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Text(
                                      data!['username'],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            );
                          },
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        widget.chatMessage.data['senderId'] == box.read('id')
                            ? widget.chatMessage.data['seenBy'].length > 1
                                ? const Icon(
                                    Icons.done_all,
                                    color: Colors.blue,
                                    size: 20.0,
                                  )
                                : const Icon(
                                    Icons.done,
                                    color: Colors.grey,
                                    size: 20.0,
                                  )
                            : const SizedBox(),
                        widget.chatMessage.data['senderId'] == box.read('id')
                            ? SizedBox(
                                width: 0.5.w,
                              )
                            : const SizedBox(),
                        // Text(
                        //   DateFormat.jm().format(widget.time.toDate()),
                        //   style: const TextStyle(
                        //       fontSize: 10.0,
                        //       color: Colors.white,
                        //       fontWeight: FontWeight.bold),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // widget.chatMessage.cat == Category.Group
            //     ? SizedBox(
            //         width: 2.w,
            //       )
            //     : const SizedBox(),
            // widget.chatMessage.cat == Category.Group
            //     ? widget.chatMessage.type == MessageType.Receiver
            //         ? const SizedBox()
            //         : StreamBuilder(
            //             stream: FirebaseFirestore.instance
            //                 .collection('users')
            //                 .doc(widget.chatMessage.id)
            //                 .snapshots(),
            //             builder: (context,
            //                 AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
            //                     snapshot) {
            //               if (!snapshot.hasData) {
            //                 return SizedBox();
            //               }
            //               final data = snapshot.data!.data();
            //               return CircleAvatar(
            //                 radius: 12,
            //                 backgroundImage: NetworkImage(data!['url']),
            //               );
            //             })
            // : SizedBox(),
          ],
        ),
      ),
    );
  }
}
