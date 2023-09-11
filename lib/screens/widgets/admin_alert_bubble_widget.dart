import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../model/chat_message.dart';

class AdminAlertBubbleWidget extends StatefulWidget {
  AdminAlertBubbleWidget(
      {Key? key, required this.chatMessage, required this.groupId})
      : super(key: key);
  ChatMessage chatMessage;
  final String groupId;
  @override
  State<AdminAlertBubbleWidget> createState() => _AdminAlertBubbleWidgetState();
}

class _AdminAlertBubbleWidgetState extends State<AdminAlertBubbleWidget> {
  final box = GetStorage();
  final _firestore = FirebaseFirestore.instance;
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            height: 100.h,
            color: Colors.black.withOpacity(0.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 60.h,
                  width:  60.h,
                  child: Image.network(
                      'https://firebasestorage.googleapis.com/v0/b/chat-app-502c1.appspot.com/o/assets%2Falert.png?alt=media&token=d2781870-0292-4d45-88ea-7e6f56c2d986'),
                ),
                Text(
                  widget.chatMessage.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
