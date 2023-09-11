import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../design/app_colors.dart';
import '../../model/user_data.dart';

class CreateGroupDialog extends StatefulWidget {
  const CreateGroupDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _firestore = FirebaseFirestore.instance;
  List groupList = [];
  bool isSelect = false;
  String? phoneNumber;
  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future updateContacts() async {
    await _firestore
        .collection("users")
        .get()
        .then((QuerySnapshot querySnapshot) async {
      querySnapshot.docs.forEach((doc) async {
        await _firestore.collection("users").doc(doc.id).update({
          'isSelected': false,
        });
      });
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await updateContacts();
  }

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
              title: const Text('Create Group'),
              actions: [
                isLoading
                    ? const SizedBox(
                        height: 15.0,
                        width: 15.0,
                        child: CircularProgressIndicator(),
                      )
                    : IconButton(
                        onPressed: () async {
                          await _firestore.collection("users").get().then(
                            (QuerySnapshot querySnapshot) {
                              for (var doc in querySnapshot.docs) {
                                if (doc['isSelected']) {
                                  groupList.add(doc['id']);
                                } else {
                                  groupList.remove(doc['id']);
                                }
                              }

                              if (groupList.isEmpty) {
                                // ignore: deprecated_member_use
                                _scaffoldKey.currentState!.showSnackBar(
                                  const SnackBar(
                                    content: Text('No users selected !'),
                                  ),
                                );
                              } else {
                                Get.dialog(
                                  const Center(
                                    child: CreateGroupWidget(),
                                  ),
                                );
                              }
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.check,
                        ),
                      )
              ],
              backgroundColor: const Color(0xff361500),
              elevation: 0.3,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection("users").snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    List<Widget> numberTiles = [];

                    for (var data in snapshot.data!.docs) {
                      // print(doc["message"]);
                      if (data['phoneNumber'] != phoneNumber) {
                        numberTiles.add(ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              data['username'][0].toUpperCase(),
                            ),
                          ),
                          title: Text(
                            data['username'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            data['phoneNumber'],
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          trailing: Checkbox(
                            value: data['isSelected'],
                            fillColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            checkColor: Colors.blue,
                            onChanged: (value) {
                              _firestore
                                  .collection("users")
                                  .doc(data.id)
                                  .update({
                                'isSelected': !data['isSelected'],
                              });
                            },
                          ),
                        ));
                      }
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

class CreateGroupWidget extends StatefulWidget {
  const CreateGroupWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<CreateGroupWidget> createState() => _CreateGroupWidgetState();
}

class _CreateGroupWidgetState extends State<CreateGroupWidget> {
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
                                    // ignore: avoid_init_to_null
                                    String? url = null;
                                    final groupId =
                                        DateTime.now().millisecondsSinceEpoch;

                                    var time = DateTime.now();

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
                                        .doc(groupId.toString())
                                        .set({
                                      'id': groupId.toString(),
                                      'groupName': groupName,
                                      'isOff': false,
                                      'url': url,
                                      'admins': [id],
                                      'message': 'New group',
                                      'messageIndex': 0,
                                      'type': 'group',
                                      'searchIndex': indexList,
                                    });

                                    await _firestore
                                        .collection("users")
                                        .get()
                                        .then((QuerySnapshot querySnapshot) {
                                      querySnapshot.docs.forEach((doc) async {
                                        if (doc['isSelected']) {
                                          await _firestore
                                              .collection("groupChats")
                                              .doc(doc['id'])
                                              .collection("myGroups")
                                              .doc(groupId.toString())
                                              .set({
                                            'id': groupId.toString(),
                                          });
                                          await _firestore
                                              .collection("groups")
                                              .doc(groupId.toString())
                                              .collection('groupMembers')
                                              .doc(doc['id'])
                                              .set({
                                            'id': doc['id'],
                                            'phone': doc['phoneNumber'],
                                            'subscription_date': time,
                                            'isAdmin': false,
                                          });
                                        }
                                      });
                                    });
                                    await _firestore
                                        .collection("groupChats")
                                        .doc(id)
                                        .collection("myGroups")
                                        .doc(groupId.toString())
                                        .set({
                                      'id': groupId.toString(),
                                    });
                                    await _firestore
                                        .collection("groups")
                                        .doc(groupId.toString())
                                        .collection('groupMembers')
                                        .doc(id)
                                        .set({
                                      'id': id,
                                      'phone': box.read('phone'),
                                      'subscription_date': time,
                                      'isAdmin': true,
                                    });
                                    await _firestore
                                        .collection("users")
                                        .get()
                                        .then((QuerySnapshot
                                            querySnapshot) async {
                                      querySnapshot.docs.forEach((doc) async {
                                        await _firestore
                                            .collection("users")
                                            .doc(doc.id)
                                            .update({
                                          'isSelected': false,
                                        });
                                      });
                                    });
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Get.snackbar(
                                      'Message',
                                      'Group successfully created!',
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
                                  'Create Group',
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
