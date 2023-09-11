import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/chat_screen_widget.dart';

class ChatMessage {
  String message;
  MessageType type;
  String messageType;
  String userImage;
  String userName;
  Category cat;
  Timestamp time;
  String videoUrl;
  String imageUrl;
  String thumbnail;
  String id;
  String msgId;
  String groupId;
  // ignore: prefer_typing_uninitialized_variables
  var data;
  ChatMessage({
    required this.message,
    required this.type,
    required this.messageType,
    required this.cat,
    required this.userImage,
    required this.userName,
    required this.time,
    required this.imageUrl,
    required this.videoUrl,
    required this.thumbnail,
    required this.id,
    required this.msgId,
    required this.groupId,
    required this.data,
  });
}
