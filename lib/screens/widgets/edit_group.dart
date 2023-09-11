import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../design/app_colors.dart';

class EditGroup extends StatefulWidget {
  EditGroup({Key? key, required this.groupName, required this.groupId}) : super(key: key);

  final String groupName;
  final String groupId;

  @override
  State<EditGroup> createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {
   final _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? groupName;
  final box = GetStorage();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final id = box.read('id');
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        color: const Color(0xff151D3B),
        height: 460.h,
        width: kIsWeb ? 500.w : 500.w,
        child: Scaffold(
          backgroundColor: const Color(0xff151D3B),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 60.0,
                    child: Icon(
                      Icons.group,
                      size: 50.0,
                    ),
                  ),
                  SizedBox(
                    height: 13.h,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 50.w,
                    ),
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          groupName = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Group Name Required !';
                        }
                        return null;
                      },
                      style: const TextStyle(color: Colors.white),
                      initialValue: widget.groupName,
                      decoration: InputDecoration(
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Icon(
                            Icons.group,
                            color: Colors.white60,
                          ),
                        ),
                        hintText: 'Group Name',
                        hintStyle: const TextStyle(
                          color: Colors.white60,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                        filled: true,
                        fillColor: Palette.searchTextFieldColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 0.0,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 0.0,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 13.h,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                    ),
                    child: ButtonTheme(
                      minWidth: kIsWeb ? 400.w : 400.w,
                      height: 60.h,
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              // ignore: deprecated_member_use
                              child: FlatButton(
                                color: Colors.white,
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    List<String> splitList =
                                        groupName!.split(" ");
                                    List<String> indexList = [];

                                    for (int i = 0; i < splitList.length; i++) {
                                      for (var y = 0;
                                          y < splitList[i].length;
                                          y++) {
                                        indexList.add(splitList[i]
                                            .substring(0, y)
                                            .toLowerCase());
                                      }
                                    }

                                    await _firestore
                                        .collection("groups")
                                        .doc(widget.groupId)
                                        .update({
                                      'groupName': groupName,
                                      'searchIndex': indexList,
                                    });

                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Get.snackbar(
                                      'Message',
                                      'Group name successfully edited!',
                                      maxWidth: 350.w,
                                      colorText: Colors.white,
                                    );
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                },
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  'Edit Group',
                                  style: TextStyle(
                                    color: Palette.appColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}