import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filesize/filesize.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import '../../design/app_colors.dart';
import 'package:path/path.dart' as p;

class FileSendWidget extends StatefulWidget {
  const FileSendWidget({
    Key? key,
    required this.groupId,
    this.result,
    required this.isDrop,
    this.data,
  }) : super(key: key);

  final String groupId;
  final result;
  final bool isDrop;
  final data;

  @override
  State<FileSendWidget> createState() => _FileSendWidgetState();
}

class _FileSendWidgetState extends State<FileSendWidget> {
  final box = GetStorage();
  bool isLoading = false;
  final _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: SizedBox(
        width: kIsWeb ? 300.w : 300.w,
        height: 170.h,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Palette.appColor,
            title: const Text(
              'Send File',
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  final fileId = DateTime.now().millisecondsSinceEpoch;
                  final fileSize = filesize(widget.result.files.single.size);
                  final fileName = widget.result.files.single.name;
                  final String ext = p.extension(fileName);
                  final Reference fireStorageRef = FirebaseStorage.instance
                      .ref()
                      .child("Chat files")
                      .child(fileId.toString() + ext);
                  if (kIsWeb) {
                    await fireStorageRef.putData(widget.isDrop
                        ? widget.data
                        : widget.result.files.single.bytes!);
                  } else {
                    await fireStorageRef.putFile(
                      File(
                        widget.result.files.single.path,
                      ),
                    );
                  }

                  String? url = await fireStorageRef.getDownloadURL();

                  await _firestore
                      .collection('groups')
                      .doc(widget.groupId)
                      .collection('groupMessages')
                      .doc()
                      .set({
                    "isMe": true,
                    'type': 'file',
                    'fileUrl': url,
                    'senderName': box.read('username'),
                    'senderId': box.read('id'),
                    'message': '',
                    'senderPhone': box.read('phone'),
                    'new': true,
                    'fileName': fileName,
                    'fileSize': fileSize,
                    'seenBy': [],
                    "time": DateTime.now(),
                  });
                  await _firestore
                      .collection('groups')
                      .doc(widget.groupId)
                      .update({
                    'message': 'File message',
                  });
                  setState(() {
                    isLoading = false;
                  });
                  Navigator.pop(context);
                },
                icon: isLoading
                    ? const CircularProgressIndicator()
                    : const Icon(
                        Icons.send,
                      ),
              )
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(
                8.0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: kIsWeb
                    ? const Icon(
                        Icons.file_present_outlined,
                        size: 70,
                      )
                    : const Icon(
                        Icons.file_present_outlined,
                        size: 30,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
