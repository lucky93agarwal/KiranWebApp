// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../model/chat_message.dart';
import '../chat_screen_widget.dart';

class VideoChatBubble extends StatefulWidget {
  ChatMessage chatMessage;
  VideoChatBubble({Key? key, required this.chatMessage}) : super(key: key);

  @override
  _VideoChatBubbleState createState() => _VideoChatBubbleState();
}

class _VideoChatBubbleState extends State<VideoChatBubble> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: (widget.chatMessage.type == MessageType.Receiver
            ? MainAxisAlignment.start
            : MainAxisAlignment.end),
        children: [
          widget.chatMessage.cat == Category.Group
              ? widget.chatMessage.type == MessageType.Receiver
                  ? StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.chatMessage.id)
                          .snapshots(),
                      builder: (context,
                          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox();
                        }
                        final data = snapshot.data!.data();
                        return CircleAvatar(
                          radius: 12,
                          backgroundImage: NetworkImage(data!['url']),
                        );
                      })
                  : const SizedBox()
              : const SizedBox(),
          widget.chatMessage.cat == Category.Group
              ? SizedBox(
                  width: 2.w,
                )
              : const SizedBox(),
          Column(
            crossAxisAlignment: (widget.chatMessage.type == MessageType.Receiver
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end),
            children: [
              Container(
                height: 20.h,
                width: 20.w,
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
                padding: const EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(30),
                    image: DecorationImage(
                      image: NetworkImage(
                        widget.chatMessage.thumbnail,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.play_circle,
                      size: 50,
                    ),
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => ChatVideoPlay(
                      //       videoUrl: widget.chatMessage.videoUrl,
                      //     ),
                      //   ),
                      // );
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 2.w,
              ),
              Text(
                DateFormat.jm().format(widget.chatMessage.time.toDate()),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            ],
          ),
          widget.chatMessage.cat == Category.Group
              ? SizedBox(
                  width: 2.w,
                )
              : const SizedBox(),
          widget.chatMessage.cat == Category.Group
              ? widget.chatMessage.type == MessageType.Receiver
                  ? const SizedBox()
                  : StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.chatMessage.id)
                          .snapshots(),
                      builder: (context,
                          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox();
                        }
                        final data = snapshot.data!.data();
                        return CircleAvatar(
                          radius: 12,
                          child: Text(widget.chatMessage.userName[0].toUpperCase()),
                        );
                      })
              : const SizedBox(),
        ],
      ),
    );
  }
}
