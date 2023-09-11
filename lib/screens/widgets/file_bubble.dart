import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:html' as html;
import '../../controllers/app_controller.dart';
import '../../model/chat_message.dart';
import '../chat_screen_widget.dart';

// ignore: must_be_immutable
class FileBubble extends StatefulWidget {
  ChatMessage chatMessage;
  FileBubble({
    Key? key,
    required this.chatMessage,
    required this.groupId,
  }) : super(key: key);
  final String groupId;
  @override
  _FileBubbleState createState() => _FileBubbleState();
}

class _FileBubbleState extends State<FileBubble> {
  AppControllers appcontroller = Get.put(AppControllers());
  final _firestore = FirebaseFirestore.instance;
  final box = GetStorage();

  //download file
  void downloadFile(String url) {
    // ignore: unnecessary_new
    html.AnchorElement anchorElement = new html.AnchorElement(href: url);
    anchorElement.download = url;
    anchorElement.click();
  }

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
                              ? 150.h
                              : 250.h
                          : widget.chatMessage.type == MessageType.Receiver
                              ? 150.h
                              : 250.h
                      : 250.h,
                  width: kIsWeb ? 230.w : 230.w,
                  child: Column(
                    children: [
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
            child: Padding(
              padding: widget.chatMessage.type == MessageType.Receiver
                  ? EdgeInsets.only(right: 500.0.w, left: 6.w)
                  : EdgeInsets.only(left: 500.0.w, right: 6.w),
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
                      vertical: 3.0, horizontal: 5.0),
                  child: Column(
                    crossAxisAlignment:
                        widget.chatMessage.type != MessageType.Receiver
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Colors.black.withOpacity(
                              0.5,
                            ),
                          ),
                        ),
                        tileColor: Colors.white,
                        leading: const Icon(
                          Icons.file_present,
                        ),
                        title: Text(widget.chatMessage.data['fileName']),
                        subtitle: Text(
                            'Xsl - ${widget.chatMessage.data['fileSize']}'),
                        trailing: GestureDetector(
                          onTap: () {
                            downloadFile(widget.chatMessage.data['fileUrl']);
                          },
                          child: const Icon(
                            Icons.download,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 5.0,
          ),
          Padding(
            padding: widget.chatMessage.type == MessageType.Receiver
                ? const EdgeInsets.only(right: 12.0)
                : const EdgeInsets.only(left: 12.0),
            child: Row(
              mainAxisAlignment: widget.chatMessage.type != MessageType.Receiver
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 0.5.w,
                ),
                Text(
                  DateFormat.jm().format(widget.chatMessage.time.toDate()),
                  style: const TextStyle(
                      fontSize: 10.0,
                      color: Colors.white60,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 0.5.w,
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
                        widget.chatMessage.userName,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                SizedBox(
                  width: 0.5.w,
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
