import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../design/app_colors.dart';
import '../../services/service_functions.dart';

class YesOrNoClearGroupMessagesWidget extends StatefulWidget {
  const YesOrNoClearGroupMessagesWidget({
    Key? key,
    required this.groupId,
    required this.isOneChat,
  }) : super(key: key);
  final String groupId;
  final bool isOneChat;
  @override
  State<YesOrNoClearGroupMessagesWidget> createState() =>
      _YesOrNoClearGroupMessagesWidgetState();
}

class _YesOrNoClearGroupMessagesWidgetState
    extends State<YesOrNoClearGroupMessagesWidget> {
  final box = GetStorage();
  bool isLoading = false;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        color: Palette.appColor,
        height: kIsWeb ? 230.h : 200.h,
        width: kIsWeb ? 330.w : 300.0.w,
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(
              Icons.clear_all,
            ),
            title: Text(
              widget.isOneChat
                  ? 'Clear chat messages'
                  : box.read('isGroup')
                      ? 'Clear group messages'
                      : 'Clear Channel messages',
            ),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black,
          ),
          backgroundColor: Palette.secondColor,
          body: Container(
            color: Palette.searchTextFieldColor,
            child: Column(
              children: [
                SizedBox(
                  height: 15.h,
                ),
                Text(
                  widget.isOneChat
                      ? 'Are sure you want to clear the messages of this chat ?'
                      : box.read('isGroup')
                          ? 'Are sure you want to clear the messages of this group ?'
                          : 'Are sure you want to clear the messages of this channel ?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 15.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ButtonTheme(
                      minWidth: kIsWeb ? 100.w : 100.w,
                      height: 60.h,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              // ignore: deprecated_member_use
                              child: FlatButton(
                                color: Palette.appColor,
                                onPressed: () async {
                                  setState(() {
                                    isLoading = true;
                                  });

                                  _firestore
                                      .collection('groups')
                                      .doc(widget.groupId)
                                      .collection('groupMessages')
                                      .get()
                                      .then((value) {
                                    for (var el in value.docs) {
                                      _firestore
                                          .collection('groups')
                                          .doc(widget.groupId)
                                          .collection('groupMessages')
                                          .doc(el.id)
                                          .delete();
                                    }
                                  });
                                  _firestore
                                      .collection('groups')
                                      .doc(widget.groupId)
                                      .update({
                                    'messageIndex': 0,
                                  });
                                  Get.snackbar(
                                    'Info',
                                    'Successfully cleared the groups messages',
                                    colorText: Colors.white,
                                    maxWidth: 350.w,
                                    duration: const Duration(
                                      seconds: 2,
                                    ),
                                  );
                                  setState(() {
                                    isLoading = false;
                                  });
                                  Navigator.pop(context);
                                },
                                padding: const EdgeInsets.all(5),
                                child: const Text(
                                  'Yes',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    SizedBox(
                      width: 15.w,
                    ),
                    ButtonTheme(
                      minWidth: kIsWeb ? 100.w : 100.w,
                      height: 60.h,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                        // ignore: deprecated_member_use
                        child: FlatButton(
                          color: Colors.grey[300],
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          padding: const EdgeInsets.all(5),
                          child: const Text(
                            'No',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
