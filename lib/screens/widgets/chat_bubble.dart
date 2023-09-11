import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';
import 'package:link_text/link_text.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/app_controller.dart';
import '../../model/chat_message.dart';
import '../chat_screen_widget.dart';

// ignore: must_be_immutable
class ChatBubble extends StatefulWidget {
  ChatMessage chatMessage;
  ChatBubble({
    Key? key,
    required this.chatMessage,
    required this.groupId,
  }) : super(key: key);
  final String groupId;
  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  AppControllers appcontroller = Get.put(AppControllers());
  final _firestore = FirebaseFirestore.instance;
  final box = GetStorage();
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
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
      child: Column(
        crossAxisAlignment: widget.chatMessage.type != MessageType.Receiver
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: <Widget>[
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
                              ?  150.h
                              :  250.h
                          : widget.chatMessage.type == MessageType.Receiver
                              ? 150.h
                              :  250.h
                      : 250.h,
                  width: kIsWeb ? 230.w : 230.w,
                  child: Column(
                    children: [
                      box.read('isAdmin')
                          ? Flexible(
                              child: ListTile(
                                onTap: () {
                                  FlutterClipboard.copy(
                                          widget.chatMessage.message)
                                      .then((value) {
                                    Get.snackbar(
                                      'Message',
                                      'Copied',
                                      padding: const EdgeInsets.all(8.0),
                                      colorText: Colors.white,
                                      maxWidth: 300.w,
                                    );
                                  });
                                  Get.back();
                                },
                                shape: const StadiumBorder(),
                                leading: const Icon(
                                  Icons.copy,
                                  color: Colors.white,
                                ),
                                title: const Text(
                                  'Copy',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(),
                      widget.chatMessage.type == MessageType.Receiver
                          ? const SizedBox()
                          : Flexible(
                              child: ListTile(
                                onTap: () {
                                  Get.find<AppControllers>()
                                      .setTextFieldController(
                                          text: widget.chatMessage.message);
                                  Get.find<AppControllers>().setMessageEdit(
                                      isEdit: true,
                                      msgId: widget.chatMessage.msgId);
                                  Navigator.pop(context);
                                },
                                shape: const StadiumBorder(),
                                leading: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                                title: const Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                      Flexible(
                        child: ListTile(
                          onTap: () {
                            Get.find<AppControllers>()
                                .setInputFocus();
                            Get.find<AppControllers>().setMessageReply(
                              isReply: true,
                              msgId: widget.chatMessage.msgId,
                              message: widget.chatMessage.message,
                              username: widget.chatMessage.userName,
                            );
                            Navigator.pop(context);
                          },
                          shape: const StadiumBorder(),
                          leading: const Icon(Icons.reply, color: Colors.white),
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
                                  Get.back();
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
            child: Padding(
              padding: widget.chatMessage.type == MessageType.Receiver
                  ? EdgeInsets.only(right: 300.0.w, left: 6.w)
                  : EdgeInsets.only(left: 300.0.w, right: 6.w),
              child: Material(
                borderRadius: widget.chatMessage.type != MessageType.Receiver
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(0.0),
                      )
                    : const BorderRadius.only(
                        topRight: Radius.circular(20.0),
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(0.0),
                        bottomRight: Radius.circular(20.0),
                      ),
                elevation: 3.0,
                color: widget.chatMessage.type != MessageType.Receiver
                    ? Colors.blueAccent
                    : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment:
                        widget.chatMessage.type != MessageType.Receiver
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: <Widget>[
                      LinkText(
                        widget.chatMessage.message,
                        linkStyle: TextStyle(
                          color: widget.chatMessage.type != MessageType.Receiver
                              ? Colors.yellow
                              : Colors.blue,
                        ),
                        textStyle: TextStyle(
                          fontSize: 13.0,
                          color: widget.chatMessage.type != MessageType.Receiver
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
           SizedBox(
            height: 5.h,
          ),
          Padding(
            padding: widget.chatMessage.type == MessageType.Receiver
                ?  EdgeInsets.only(right: 12.0.w)
                :  EdgeInsets.only(left: 12.0.w),
            child: Row(
              mainAxisAlignment: widget.chatMessage.type != MessageType.Receiver
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 6.w,
                ),
                Text(
                  DateFormat.jm().format(widget.chatMessage.time.toDate()),
                  style: const TextStyle(
                      fontSize: 10.0,
                      color: Colors.white60,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 6.w,
                ),
                widget.chatMessage.data['senderId'] == box.read('id')
                    ? const Text(
                        'Me',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Text(
                        widget.chatMessage.userName == null ?"": widget.chatMessage.userName,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                SizedBox(
                  width: 6.w,
                ),
               widget.chatMessage.data['senderId'] == box.read('id') ?  widget.chatMessage.data['seenBy'].length > 1
                    ? const Icon(
                        Icons.done_all,
                        color: Colors.blue,
                        size: 20.0,
                      )
                    : const Icon(
                        Icons.done,
                        color: Colors.grey,
                        size: 20.0,
                      ) : const SizedBox(),
               widget.chatMessage.data['senderId'] == box.read('id') ?  SizedBox(
                  width: 0.5.w,
                ) : const SizedBox(),
                // Text(
                //   widget.chatMessage.userName,
                //   style: TextStyle(
                //     fontWeight: FontWeight.bold,
                //     color: Colors.grey[700],
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




//  Container(
//           padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             mainAxisAlignment: (widget.chatMessage.type == MessageType.Receiver
//                 ? MainAxisAlignment.start
//                 : MainAxisAlignment.end),
//             children: [
//               widget.chatMessage.cat == Category.Group
//                   ? widget.chatMessage.type == MessageType.Receiver
//                       ? StreamBuilder(
//                           stream: FirebaseFirestore.instance
//                               .collection('users')
//                               .doc(widget.chatMessage.id)
//                               .snapshots(),
//                           builder: (context,
//                               AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
//                                   snapshot) {
//                             if (!snapshot.hasData) {
//                               return SizedBox();
//                             }
//                             final data = snapshot.data!.data();
//                             return CircleAvatar(
//                               radius: 12,
//                               child: Text(widget.chatMessage.userName[0]),
//                             );
//                           })
//                       : SizedBox()
//                   : SizedBox(),
//               widget.chatMessage.cat == Category.Group
//                   ? SizedBox(
//                       width: 2.w,
//                     )
//                   : SizedBox(),
//               Column(
//                 crossAxisAlignment: (widget.chatMessage.type == MessageType.Receiver
//                     ? CrossAxisAlignment.start
//                     : CrossAxisAlignment.end),
//                 children: [
//                   Container(
//                     width: 70.w,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.only(
//                           bottomLeft:
//                               widget.chatMessage.type == MessageType.Receiver
//                                   ? Radius.circular(0)
//                                   : Radius.circular(30),
//                           topLeft: Radius.circular(30),
//                           topRight: Radius.circular(30),
//                           bottomRight:
//                               widget.chatMessage.type == MessageType.Receiver
//                                   ? Radius.circular(30)
//                                   : Radius.circular(0)),
//                       color: (widget.chatMessage.type == MessageType.Receiver
//                           ? Colors.white
//                           : Colors.blueAccent),
//                     ),
//                     padding: EdgeInsets.all(16),
//                     child: Text(
//                       widget.chatMessage.message,
//                       style: TextStyle(
//                         color: widget.chatMessage.type == MessageType.Receiver
//                             ? Colors.black
//                             : Colors.white,
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 2.w,
//                   ),
//                   Text(
//                     DateFormat.jm().format(
//                       widget.chatMessage.time.toDate(),
//                     ),
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   )
//                 ],
//               ),
//               widget.chatMessage.cat == Category.Group
//                   ? SizedBox(
//                       width: 2.w,
//                     )
//                   : SizedBox(),
//               widget.chatMessage.cat == Category.Group
//                   ? widget.chatMessage.type == MessageType.Receiver
//                       ? SizedBox()
//                       : StreamBuilder(
//                           stream: FirebaseFirestore.instance
//                               .collection('users')
//                               .doc(widget.chatMessage.id)
//                               .snapshots(),
//                           builder: (context,
//                               AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
//                                   snapshot) {
//                             if (!snapshot.hasData) {
//                               return SizedBox();
//                             }
//                             final data = snapshot.data!.data();
//                             return CircleAvatar(
//                               radius: 12,
//                               child: Text(widget.chatMessage.userName[0]),
//                             );
//                           })
//                   : SizedBox(),
//             ],
//           ),
//         ),