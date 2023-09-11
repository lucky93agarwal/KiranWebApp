import 'package:any_link_preview/any_link_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:visibility_detector/visibility_detector.dart';

import '../../model/chat_message.dart';
import '../chat_screen_widget.dart';

// ignore: must_be_immutable
class LinkBubble extends StatefulWidget {
  ChatMessage chatMessage;
  LinkBubble({Key? key, required this.chatMessage, required this.groupId})
      : super(key: key);
  final String groupId;
  @override
  _LinkBubbleState createState() => _LinkBubbleState();
}

class _LinkBubbleState extends State<LinkBubble> {
  PreviewData? _previewData;
  final box = GetStorage();
  final _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: widget.chatMessage.type != MessageType.Receiver
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: widget.chatMessage.type != MessageType.Receiver
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
                              Flexible(
                                child: ListTile(
                                  onTap: () {},
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
                              ),
                              Flexible(
                                child: ListTile(
                                  onTap: () {},
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
                                  onTap: () {},
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
                              Flexible(
                                child: ListTile(
                                  onTap: () {},
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
                    child: Material(
                      borderRadius:
                          widget.chatMessage.type != MessageType.Receiver
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0),
                                  bottomLeft: Radius.circular(20.0),
                                  bottomRight: Radius.circular(0.0),
                                )
                              : const BorderRadius.only(
                                  topRight: Radius.circular(20.0),
                                  topLeft: Radius.circular(20.0),
                                  bottomLeft: Radius.circular(20.0),
                                  bottomRight: Radius.circular(0.0),
                                ),
                      elevation: 3.0,
                      color: widget.chatMessage.type != MessageType.Receiver
                          ? Color.fromARGB(255, 156, 190, 248)
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
                            // AnyLinkPreview(
                            //   link: "https://google.com/",
                            //   displayDirection: uiDirection.uiDirectionHorizontal,
                            //   showMultimedia: true,
                            //   bodyMaxLines: 5,
                            //   bodyTextOverflow: TextOverflow.ellipsis,
                            //   titleStyle: const TextStyle(
                            //     color: Colors.black,
                            //     fontWeight: FontWeight.bold,
                            //     fontSize: 15,
                            //   ),
                            //   bodyStyle: const TextStyle(
                            //       color: Colors.grey, fontSize: 12),
                            //   errorBody: 'Show my custom error body',
                            //   errorTitle: 'Show my custom error title',
                            //   errorWidget: Container(
                            //     color: Colors.grey[300],
                            //     child: const Text('Oops!'),
                            //   ),
                            //   errorImage: "https://google.com/",
                            //   cache: const Duration(days: 7),
                            //   backgroundColor: Colors.grey[300],
                            //   borderRadius: 12,
                            //   removeElevation: false,
                            //   boxShadow: const [
                            //     BoxShadow(blurRadius: 3, color: Colors.grey)
                            //   ],
                            //   onTap: () {}, // This disables tap event
                            // ),
                            LinkPreview(
                              enableAnimation: true,
                              hideImage: false,
                              onPreviewDataFetched: (data) {
                                setState(() {
                                  // Save preview data to the state
                                });
                              },
                              previewData:
                                  _previewData, // Pass the preview data from the state
                              text: widget.chatMessage.message,
                              width: MediaQuery.of(context).size.width,
                            ),
                            Text(
                              widget.chatMessage.message,
                              style: TextStyle(
                                fontSize: 13.0,
                                color: widget.chatMessage.type !=
                                        MessageType.Receiver
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // SizedBox(
                //   width: 1.w,
                // ),
                // CircleAvatar(
                //   radius: 12,
                //   child: Text(widget.chatMessage.userName[0]),
                // )
              ],
            ),
            const SizedBox(
              height: 5.0,
            ),
            Padding(
              padding: widget.chatMessage.type == MessageType.Receiver
                  ? const EdgeInsets.only(right: 12.0)
                  : const EdgeInsets.only(left: 12.0),
              child: Row(
                mainAxisAlignment:
                    widget.chatMessage.type != MessageType.Receiver
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                children: [
                  // Text(
                  //   DateFormat.jm().format(widget.chatMessage.time.toDate()),
                  //   style: TextStyle(
                  //       fontSize: 10.0,
                  //       color: Colors.black54,
                  //       fontWeight: FontWeight.bold),
                  // ),
                  // SizedBox(
                  //   width: 1.w,
                  // ),
                  Text(
                    widget.chatMessage.userName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
