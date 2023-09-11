import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class AppControllers extends GetxController {
  bool isWritting = false;

  int currentIndex = 0;

  String? currentGroupId;
  String? currentGroupType;
  String? currentUserName;
  String? editMessageId;
  String? replymessageId;
  String? replymessage;
  String? replyUsername;

  bool isMessageEdit = false;
  bool isMessageReply = false;

  TextEditingController? messageController = TextEditingController();
   var focusNode = FocusNode();

  void setCurrentGroupId({required String id, required String type}) {
    currentGroupId = id;
    currentGroupType = type;
    update();
  }

  void setInputFocus() {
    focusNode.requestFocus();
    update();
  }

  
  void setCurrentUserName({required String name}) {
    currentUserName = name;
    update();
  }

  void setCurrentIndex(int index) {
    currentIndex = index;
    update();
  }

  void setMessageEdit({required bool isEdit, required String msgId}) {
    isMessageEdit = isEdit;
    editMessageId = msgId;
    update();
  }

  void setMessageReply(
      {required bool isReply,
      required String msgId,
      required String message,
      required String username}) {
    isMessageReply = isReply;
    replymessageId = msgId;
    replymessage = message;
    replyUsername = username;
    update();
  }

  void setTextFieldController({required String text}) {
    messageController!.text = text;
    update();
  }

  void textFieldClear() {
    messageController!.clear();
    update();
  }

  void clearMessageReply(
      ){
    isMessageReply = false;
  }

  pickFiles() {}
}
