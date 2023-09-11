import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../design/app_colors.dart';
import '../../model/user_data.dart';

class CreateChannelWidget extends StatefulWidget {
  const CreateChannelWidget({Key? key}) : super(key: key);

  @override
  State<CreateChannelWidget> createState() => _CreateChannelWidgetState();
}

class _CreateChannelWidgetState extends State<CreateChannelWidget> {
  final box = GetStorage();
  final _firestore = FirebaseFirestore.instance;

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
              title: const Text('Create Announcement Channel'),
              actions: [
                IconButton(
                  onPressed: () {
                    Get.dialog(
                      const Center(
                        child: CreateChannelDialog(),
                      ),
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
                      if (data['phoneNumber'] != box.read('phone')) {
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

class CreateChannelDialog extends StatefulWidget {
  const CreateChannelDialog({Key? key}) : super(key: key);

  @override
  State<CreateChannelDialog> createState() => _CreateChannelDialogState();
}

class _CreateChannelDialogState extends State<CreateChannelDialog> {
  final _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? channelName;
  final box = GetStorage();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final id = box.read('id');
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: SingleChildScrollView(
        child: Container(
          color: const Color(0xff632626),
          height: 460.h,
          width: kIsWeb ? 500.w : 500.w,
          child: Scaffold(
            backgroundColor: const Color(0xff632626),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xff9D5353),
                      radius: 60.0,
                      child: Icon(
                        Icons.announcement_outlined,
                        size: 50.0,
                        color: Colors.white,
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
                        style: const TextStyle(color: Colors.white),
                        onChanged: (value) {
                          setState(() {
                            channelName = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Channel Name Required !';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Icon(
                              Icons.announcement_outlined,
                              color: Colors.white60,
                            ),
                          ),
                          hintText: 'Channel Name',
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
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : ButtonTheme(
                              minWidth: kIsWeb ? 400.w : 400.w,
                              height: 60.h,
                              child: ClipRRect(
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
                                      final channelId =
                                          DateTime.now().millisecondsSinceEpoch;

                                      List<String> splitList =
                                          channelName!.split(" ");
                                      List<String> indexList = [];

                                      for (int i = 0;
                                          i < splitList.length;
                                          i++) {
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
                                          .doc(channelId.toString())
                                          .set({
                                        'id': channelId.toString(),
                                        'groupName': channelName,
                                        'isOff': false,
                                        'url': url,
                                        'admins': [id],
                                        'message': 'New channel',
                                        'messageIndex': 0,
                                        'type': 'announcement',
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
                                                .doc(channelId.toString())
                                                .set({
                                              'id': channelId.toString(),
                                            });
                                            await _firestore
                                                .collection("groups")
                                                .doc(channelId.toString())
                                                .collection('groupMembers')
                                                .doc(doc['id'])
                                                .set({
                                              'id': doc['id'],
                                              'phone': doc['phoneNumber'],
                                              'isAdmin': false,
                                            });
                                          }
                                        });
                                      });
                                      await _firestore
                                          .collection("groupChats")
                                          .doc(id)
                                          .collection("myGroups")
                                          .doc(channelId.toString())
                                          .set({
                                        'id': channelId.toString(),
                                      });
                                      await _firestore
                                          .collection("groups")
                                          .doc(channelId.toString())
                                          .collection('groupMembers')
                                          .doc(id)
                                          .set({
                                        'id': id,
                                        'phone': box.read('phone'),
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
                                        'Channel successfully created!',
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
                                    'Create Channel',
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
      ),
    );
  }
}
