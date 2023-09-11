// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import '../../design/app_colors.dart';

class ImagePostWidget extends StatefulWidget {
  const ImagePostWidget(
      {Key? key,
      required this.groupId,
      this.result,
      required this.isDrop,
      this.data})
      : super(key: key);
  final String groupId;
  final result;
  final bool isDrop;
  final data;
  @override
  State<ImagePostWidget> createState() => _ImagePostWidgetState();
}

class _ImagePostWidgetState extends State<ImagePostWidget> {
  final box = GetStorage();
  bool isLoading = false;
  final _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: SizedBox(
        width: kIsWeb ? 350.w : 300.w,
        height: 350.h,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Palette.appColor,
            title: const Text(
              'Send Image',
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  final imageId = DateTime.now().millisecondsSinceEpoch;
                  final Reference fireStorageRef = FirebaseStorage.instance
                      .ref()
                      .child("Chat images")
                      .child(imageId.toString() + '.jpg');
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
                    'type': 'image',
                    'imageUrl': url,
                    'senderName': box.read('username'),
                    'senderId': box.read('id'),
                    'message': '',
                    'senderPhone': box.read('phone'),
                    'new': true,
                    'seenBy': [],
                    "time": DateTime.now(),
                  });
                  await _firestore
                      .collection('groups')
                      .doc(widget.groupId)
                      .update({
                    'message': 'Image message',
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
                    ? Image.memory(
                        Uint8List.fromList(
                          widget.isDrop
                              ? widget.data
                              : widget.result.files.single.bytes!,
                        ),
                      )
                    : Image.file(
                        File(widget.result.files.single.path),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
