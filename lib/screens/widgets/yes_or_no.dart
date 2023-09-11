import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../design/app_colors.dart';
import '../../services/service_functions.dart';

class YesOrNoWidget extends StatefulWidget {
  const YesOrNoWidget({
    Key? key,
    required this.groupId,
  }) : super(key: key);
  final String groupId;
  @override
  State<YesOrNoWidget> createState() => _YesOrNoWidgetState();
}

class _YesOrNoWidgetState extends State<YesOrNoWidget> {
  final box = GetStorage();
  bool isLoading = false;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        color: Palette.appColor,
        height: kIsWeb ? 200.h : 200.h,
        width: kIsWeb ? 300.w : 300.0.w,
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(
              Icons.delete,
            ),
            title: Text(
              box.read('isGroup') ? 'Delete group' : 'Delete Channel',
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
                  box.read('isGroup')
                      ? 'Are sure you want to delete this group ?'
                      : 'Are sure you want to delete this channel ?',
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
                              child: FlatButton(
                                color: Palette.appColor,
                                onPressed: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await _firestore
                                      .collection('groups')
                                      .doc(widget.groupId)
                                      .delete();

                                  await _firestore
                                      .collection('groups')
                                      .doc(widget.groupId)
                                      .collection('groupMembers')
                                      .get()
                                      .then(
                                    (value) async {
                                      for (var item in value.docs) {
                                        await _firestore
                                            .collection('groupChats')
                                            .doc(
                                              item.id,
                                            )
                                            .collection('myGroups')
                                            .doc(widget.groupId)
                                            .delete();
                                      }
                                    },
                                  );
                                  await ServicesFunctions()
                                      .removeDeletedMyGroups();
                                  Get.snackbar(
                                    'Message',
                                    box.read('isGroup')
                                        ? 'Group successfully deleted!'
                                        : 'Channel successfully deleted!',
                                    maxWidth: 350.w,
                                    colorText: Colors.white,
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
