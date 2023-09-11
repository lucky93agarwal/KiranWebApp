// ignore_for_file: prefer_typing_uninitialized_variables, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_range_form_field/date_range_form_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../design/app_colors.dart';

class TransferUsers extends StatefulWidget {
  const TransferUsers({Key? key, required this.groupId}) : super(key: key);
  final String groupId;
  @override
  State<TransferUsers> createState() => _TransferUsersState();
}

class _TransferUsersState extends State<TransferUsers> {
  final _firestore = FirebaseFirestore.instance;
  List groupList = [];
  bool isSelect = false;
  String? phoneNumber;
  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff1C0A00),
      height: 700.h,
      width: kIsWeb ? 500.w : 500.w,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xff1C0A00),
        body: Column(
          children: [
            AppBar(
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.close,
                ),
              ),
              title: const Text('Transfer Users'),
              backgroundColor: const Color(0xff361500),
              elevation: 0.3,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection("groups")
                      .doc(widget.groupId)
                      .collection('groupMembers')
                      .snapshots(),
                  builder: (context, snapshotData) {
                    if (snapshotData.hasError) {
                      return const Text('Something went wrong');
                    }
                    if (!snapshotData.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshotData.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    List<Widget> numberTiles = [];

                    for (var data in snapshotData.data!.docs) {
                      // print(doc["message"]);

                      numberTiles.add(
                        FutureBuilder<DocumentSnapshot>(
                            future: _firestore
                                .collection("users")
                                .doc(data.id)
                                .get(),
                            builder: (BuildContext context,
                                AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return const Text("Something went wrong");
                              }

                              if (snapshot.hasData && !snapshot.data!.exists) {
                                return const Text("Document does not exist");
                              }

                              if (!snapshot.hasData) {
                                return const SizedBox();
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              Map<String, dynamic> info =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    info['username'][0].toUpperCase(),
                                  ),
                                ),
                                title: Text(
                                  info['username'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  info['phoneNumber'],
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                                trailing: FlatButton(
                                  color: Palette.mainColor,
                                  onPressed: () {
                                    Get.dialog(
                                      Center(
                                        child: TransferUsersDialog(
                                          phoneNumber: info['phoneNumber'],
                                          userId: info['id'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            }),
                      );
                    }
                    return ListView(
                      scrollDirection: Axis.vertical,
                      children: numberTiles,
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class TransferUsersDialog extends StatefulWidget {
  const TransferUsersDialog(
      {Key? key, required this.userId, required this.phoneNumber})
      : super(key: key);
  final String userId;
  final String phoneNumber;
  @override
  State<TransferUsersDialog> createState() => _TransferUsersDialogState();
}

class _TransferUsersDialogState extends State<TransferUsersDialog> {
  DateTimeRange? myDateRange;
  var groupSelected;
  List<String> groups = [];

  String currentGroupId = '';

  var groupsIds = [];

  final _firestore = FirebaseFirestore.instance;
  final box = GetStorage();
  bool isLoading = false;
  var startDate;
  var endDate;

  var permissionSelected;
  var permissions = [
    "Admin",
    "Normal User",
  ];

  Future getGroups() async {
    await _firestore.collection('groups').get().then((value) {
      for (var group in value.docs) {
        groups.add(group['groupName']);
        groupsIds.add(group.id);
      }
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await getGroups();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        color: const Color.fromARGB(255, 54, 54, 54),
        height: 460.h,
        width: kIsWeb ? 500.w : 500.w,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Transfer User'),
            backgroundColor: Palette.mainColor,
            automaticallyImplyLeading: false,
            elevation: 0.0,
          ),
          backgroundColor: const Color.fromARGB(255, 54, 54, 54),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5.w,
                  ),
                  child: dropdownInput(
                    size,
                    textFieldDecoration(
                      const Icon(
                        Icons.groups,
                        color: Colors.white60,
                      ),
                      'Choose Group',
                    ),
                    'Choose Group',
                    'Choose Group',
                    groups,
                    groupSelected,
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5.w,
                  ),
                  child: permissionDropdownInput(
                    size,
                    textFieldDecoration(
                      const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white60,
                      ),
                      'User Permission',
                    ),
                    'User Permissionp',
                    'User Permission',
                    permissions,
                    permissionSelected,
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5.w,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: ButtonTheme(
                      minWidth: 400.w,
                      height: 60.h,
                      buttonColor: Palette.searchTextFieldColor,
                      child: FlatButton(
                        color: Palette.searchTextFieldColor,
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            initialDate: DateTime(2022),
                            firstDate: DateTime(1970),
                            lastDate: DateTime(2070),
                          ).then((value) {
                            setState(() {
                              startDate = value;
                            });
                          });
                        },
                        child: startDate != null
                            ? Text(
                                startDate != null
                                    ? "${startDate.year}/${startDate.month}/${startDate.day}"
                                    : "Start Date",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w100,
                                ),
                              )
                            : const Text(
                                'Start Date',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w100,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5.w,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: ButtonTheme(
                      minWidth: 400.w,
                      height: 60.h,
                      buttonColor: Palette.searchTextFieldColor,
                      child: FlatButton(
                        color: Palette.searchTextFieldColor,
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            initialDate: DateTime(2022),
                            firstDate: DateTime(1970),
                            lastDate: DateTime(2070),
                          ).then((value) {
                            setState(() {
                              endDate = value;
                            });
                          });
                          ;
                        },
                        child: endDate != null
                            ? Text(
                                endDate != null
                                    ? "${endDate.year}/${endDate.month}/${endDate.day}"
                                    : "End Date",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w100,
                                ),
                              )
                            : const Text(
                                'End Date',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w100,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5.w,
                  ),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ButtonTheme(
                          minWidth: 400.w,
                          height: 60.h,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            // ignore: deprecated_member_use
                            child: FlatButton(
                              color: Colors.white,
                              onPressed: () async {
                                if (groupSelected != null &&
                                    startDate != null &&
                                    endDate != null) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  String groupId =
                                      groupsIds[groups.indexOf(groupSelected)];
                                  await _firestore
                                      .collection("groups")
                                      .doc(groupId)
                                      .collection('groupMembers')
                                      .doc(widget.userId)
                                      .set({
                                    'id': widget.userId,
                                    'isAdmin': permissionSelected == 'Admin'
                                        ? true
                                        : false,
                                    'phone': widget.phoneNumber,
                                    'startDate': startDate,
                                    'endDate': endDate,
                                  });
                                  await _firestore
                                      .collection('groupChats')
                                      .doc(
                                        widget.userId,
                                      )
                                      .collection('myGroups')
                                      .doc(groupId)
                                      .set({
                                    'id': groupId,
                                  });
                                  Get.snackbar(
                                    'Message',
                                    'User successfully transfered to the $groupSelected group.',
                                    maxWidth: 350.w,
                                    colorText: Colors.white,
                                  );
                                  setState(() {
                                    isLoading = false;
                                  });
                                  Navigator.pop(context);
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    'Group , start date and end date required!',
                                    maxWidth: 350.w,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                              padding: const EdgeInsets.all(5),
                              child: Text(
                                'Proceed',
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
    );
  }

  Widget dropdownInput(var size, var decoration, String text, String? hint,
      List<String> data, var selectedValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormField<String>(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select group';
            }
            return null;
          },
          builder: (FormFieldState<String> state) {
            return InputDecorator(
              decoration: decoration,
              isEmpty: selectedValue == '',
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedValue,
                  isDense: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      groupSelected = newValue;
                    });
                  },
                  items: data.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  hint: Text(
                    hint.toString(),
                    style: const TextStyle(
                      color: Colors.white60,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget permissionDropdownInput(var size, var decoration, String text,
      String? hint, List<String> data, var selectedValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormField<String>(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select group';
            }
            return null;
          },
          builder: (FormFieldState<String> state) {
            return InputDecorator(
              decoration: decoration,
              isEmpty: selectedValue == '',
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedValue,
                  isDense: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      permissionSelected = newValue;
                    });
                  },
                  items: data.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  hint: Text(
                    hint.toString(),
                    style: const TextStyle(
                      color: Colors.white60,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

InputDecoration textFieldDecoration(var prefix, String hint) {
  return InputDecoration(
    filled: true,
    prefixIcon: prefix,
    hintText: hint,
    fillColor: Palette.searchTextFieldColor,
    hintStyle: const TextStyle(
      color: Colors.white60,
    ),
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(10.0),
      ),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(10.0),
      ),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(10.0),
        ),
        borderSide: BorderSide(
          color: Palette.appColor,
        )),
  );
}
