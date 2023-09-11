// ignore: must_be_immutable
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/app_controller.dart';
import '../chat_screen_widget.dart';

final _firestore = FirebaseFirestore.instance;

// ignore: must_be_immutable
class MessageReplyBubble extends StatefulWidget {
  MessageReplyBubble({
    Key? key,
    required this.text,
    required this.isMe,
    required this.time,
    required this.documentID,
    required this.isStarred,
    required this.replyId,
    required this.groupId,
    required this.senderId,
    required this.username,
    required this.chatMessage,
  }) : super(key: key);
  final String text;
  final String groupId;
  final Timestamp time;
  String documentID;
  String senderId;
  bool isMe;
  bool isStarred;
  final String replyId;
  final String username;
  final chatMessage;

  @override
  State<MessageReplyBubble> createState() => _MessageReplyBubbleState();
}

class _MessageReplyBubbleState extends State<MessageReplyBubble> {
  final box = GetStorage();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(3.0),
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
        child: Column(
          crossAxisAlignment: widget.senderId == box.read('id')
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: widget.senderId == box.read('id')
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                const Flexible(
                  child: SizedBox(),
                ),
                Flexible(
                  child: PopupMenuButton<String>(
                    color: Colors.transparent,
                    elevation: 0.0,
                    tooltip: '',
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
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
                                  ? widget.chatMessage.type ==
                                          MessageType.Receiver
                                      ? 150.h
                                      : 250.h
                                  : widget.chatMessage.type ==
                                          MessageType.Receiver
                                      ? 150.h
                                      : 250.h
                              : 250.h,
                          width: kIsWeb ? 230.w : 230.w,
                          child: Column(
                            children: [
                              box.read('isAdmin')
                                  ? Flexible(
                                      child: ListTile(
                                        onTap: () {
                                          FlutterClipboard.copy(widget.text)
                                              .then((value) {
                                            Get.snackbar(
                                              'Message',
                                              'Copied',
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
                              Flexible(
                                child: ListTile(
                                  onTap: () {
                                    Get.find<AppControllers>()
                                        .setTextFieldController(
                                            text: widget.text);
                                    Get.find<AppControllers>().setMessageEdit(
                                        isEdit: true, msgId: widget.documentID);
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
                                    Get.find<AppControllers>().setMessageReply(
                                      isReply: true,
                                      msgId: widget.documentID,
                                      message: widget.text,
                                      username: widget.username,
                                    );
                                    Navigator.pop(context);
                                  },
                                  shape: const StadiumBorder(),
                                  leading: const Icon(Icons.reply,
                                      color: Colors.white),
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
                              box.read('isAdmin')
                                  ? Flexible(
                                      child: ListTile(
                                        onTap: () async {
                                          await _firestore
                                              .collection('groups')
                                              .doc(widget.groupId)
                                              .collection('groupMessages')
                                              .doc(widget.documentID)
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
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    ],
                    child: Material(
                      borderRadius: widget.senderId == box.read('id')
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
                      color: widget.senderId == box.read('id')
                          //Big Box Color
                          ? const Color(0xffccdadb)
                          : const Color(0xff1f211e),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: widget.senderId != box.read('id')
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: size.width * 0.5,
                              child: StreamBuilder(
                                  stream: _firestore
                                      .collection('groups')
                                      .doc(widget.groupId)
                                      .collection('groupMessages')
                                      .doc(widget.replyId)
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<
                                              DocumentSnapshot<
                                                  Map<String, dynamic>>>
                                          snapshot) {
                                    if (!snapshot.hasData) {
                                      return const SizedBox();
                                    }
                                    final data = snapshot.data!.data();
                                    return ListTile(
                                      tileColor: widget.senderId ==
                                              box.read('id')
                                          // COLOR FIR INSIDE TEH BIG BOX...................................>>>>>>>>>>>>>>>>>>>
                                          ? const Color(0xff303434)
                                              .withOpacity(0.6)
                                          // Colors.white.withOpacity(0.6)
                                          : const Color(0xff303434),
                                      leading: data!['type'] == 'image'
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 2.0,
                                              ),
                                              child: Container(
                                                width: 50,
                                                height: 50,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                  child: Image.network(
                                                    data['imageUrl'],
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                              ),
                                            )
                                          : data['type'] == 'audio'
                                              ? Container(
                                                  width: 50,
                                                  height: 50,
                                                  color: Colors.grey[100],
                                                  child: const Icon(
                                                    Icons.headphones,
                                                    color: Colors.blueGrey,
                                                  ),
                                                )
                                              : data['type'] == 'file'
                                                  ? Container(
                                                      width: 50,
                                                      height: 50,
                                                      color: Colors.grey[100],
                                                      child: const Icon(
                                                        FontAwesomeIcons.file,
                                                        color: Colors.blueGrey,
                                                      ),
                                                    )
                                                  : data['type'] == 'text'
                                                      ?
                                                      // MESSAGE ICON BOX CONTAINTER............................................
                                                      Container(
                                                          width: 50,
                                                          height: 50,
                                                          color: const Color(
                                                              0xff303434),
                                                          child: const Icon(
                                                            Icons.chat,
                                                            color:
                                                                Colors.blueGrey,
                                                          ),
                                                        )
                                                      : Container(
                                                          width: 50,
                                                          height: 50,
                                                          color:
                                                              Colors.grey[100],
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0),
                                                            child:
                                                                Image.network(
                                                              'https://media.wired.com/photos/59269cd37034dc5f91bec0f1/191:100/w_1280,c_limit/GoogleMapTA.jpg',
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                      title: Text(
                                              'Reply to ${data['senderName']}',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                      subtitle: data['type'] == 'image'
                                          ? const Text(
                                              'image',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : data['type'] == 'audio'
                                              ? Text(
                                                  data['name'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )
                                              : data['type'] == 'file'
                                                  ? Text(
                                                      data['name'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : data['type'] == 'text'
                                                      ? Text(
                                                          data['message'],
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : Text(
                                                          data['address'],
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                      // subtitle: data['type'] == 'image'
                                      //     ? Text(
                                      //         data['fileSize'],
                                      //         style: const TextStyle(
                                      //           color: Colors.grey,
                                      //           fontWeight: FontWeight.bold,
                                      //         ),
                                      //       )
                                      //     : data['type'] == 'audio'
                                      //         ? Text(data['fileSize'])
                                      //         : data['messageType'] == 'file'
                                      //             ? Text(data['fileSize'])
                                      //             : data['messageType'] == 'text'
                                      //                 ? const Text(
                                      //                     'Message',
                                      //                     style: TextStyle(
                                      //                       color: Colors.grey,
                                      //                       fontWeight:
                                      //                           FontWeight.bold,
                                      //                     ),
                                      //                   )
                                      //                 : Text(
                                      //                     '${data['lat']}, ${data['long']} '),
                                    );
                                  }),
                            ),
                            Container(
                              margin: const EdgeInsets.all(6.0),
                              child: Text(
                                widget.text,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: widget.senderId == box.read('id')
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5.0,
            ),
            Padding(
              padding: widget.senderId == box.read('id')
                  ? const EdgeInsets.only(right: 12.0)
                  : const EdgeInsets.only(left: 12.0),
              child: Row(
                mainAxisAlignment: widget.senderId == box.read('id')
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.jm().format(widget.time.toDate()),
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
                        .doc(widget.senderId)
                        .snapshots(),
                    builder: (context,
                        AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox();
                      }
                      final data = snapshot.data!.data();
                      return Padding(
                        padding: widget.senderId != box.read('id')
                            ? const EdgeInsets.only(right: 12.0)
                            : const EdgeInsets.only(left: 12.0),
                        child: widget.senderId == box.read('id')
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
    );
  }
}
