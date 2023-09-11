import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import '../../design/app_colors.dart';
import 'package:get/get.dart';

class AddPeopleDialog extends StatefulWidget {
  const AddPeopleDialog({Key? key, required this.groupId}) : super(key: key);
  final String groupId;
  @override
  State<AddPeopleDialog> createState() => _AddPeopleDialogState();
}

class _AddPeopleDialogState extends State<AddPeopleDialog> {
  final _firestore = FirebaseFirestore.instance;
  final box = GetStorage();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final phoneNumber = box.read('phone');
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        height: 700.h,
        width: kIsWeb ? 500.w : 500.w,
        color: Palette.secondColor,
        child: Scaffold(
            backgroundColor: Palette.secondColor,
            appBar: AppBar(
              backgroundColor: Palette.mainColor,
              title: const Text('Add People'),
              elevation: 0.0,
              automaticallyImplyLeading: false,
            ),
            body: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 4.0,
                  ),
                  // color: Palette.searchTextFieldColor,
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Icon(
                          Icons.search,
                          color: Colors.white60,
                        ),
                      ),
                      hintText: 'Search',
                      hintStyle: const TextStyle(
                        color: Colors.white60,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                      filled: true,
                      fillColor: Palette.searchTextFieldColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore.collection("users").snapshots(),
                      builder: (context, snapshotData) {
                        if (snapshotData.hasError) {
                          return const Text('Something went wrong');
                        }
                        if (!snapshotData.hasData) {
                          return const SizedBox();
                        }

                        // if (snapshot.connectionState ==
                        //     ConnectionState.waiting) {
                        //   return const Center(
                        //     child: CircularProgressIndicator(),
                        //   );
                        // }
                        List<Widget> numberTiles = [];

                        for (var data in snapshotData.data!.docs) {
                          // print(doc["message"]);

                          if (data['phoneNumber'] != phoneNumber) {
                            numberTiles.add(FutureBuilder<DocumentSnapshot>(
                                future: _firestore
                                    .collection("groups")
                                    .doc(widget.groupId)
                                    .collection('groupMembers')
                                    .doc(data.id)
                                    .get(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                                  if (snapshot.hasError) {
                                    return const Text("Something went wrong");
                                  }

                                  // if (snapshot.hasData &&
                                  //     !snapshot.data!.exists) {
                                  //   return const Text(
                                  //       "Document does not exist");
                                  // }

                                  if (!snapshot.hasData) {
                                    return const SizedBox();
                                  }

                                  // Map<String, dynamic> info = snapshot.data!
                                  //     .data() as Map<String, dynamic>;
                                  return snapshot.data!.exists
                                      ? const SizedBox()
                                      : ListTile(
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
                                          trailing: isLoading
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                )
                                              : IconButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      isLoading = true;
                                                    });
                                                    await _firestore
                                                        .collection("groups")
                                                        .doc(widget.groupId)
                                                        .collection(
                                                            'groupMembers')
                                                        .doc(snapshot.data!.id)
                                                        .set({
                                                      'id': snapshot.data!.id,
                                                      'isAdmin': false,
                                                      'phone':
                                                          data['phoneNumber'],
                                                    });
                                                    await _firestore
                                                        .collection(
                                                            'groupChats')
                                                        .doc(
                                                          snapshot.data!.id,
                                                        )
                                                        .collection('myGroups')
                                                        .doc(widget.groupId)
                                                        .set({
                                                      'id': widget.groupId,
                                                    });
                                                    Get.snackbar(
                                                      'Message',
                                                      'User successfully added to the group !',
                                                      maxWidth: 300.w,
                                                      colorText: Colors.white,
                                                    );
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                  },
                                                  icon: const Icon(
                                                    Icons.add,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        );
                                }));
                          }
                        }
                        return ListView(
                          scrollDirection: Axis.vertical,
                          children: numberTiles,
                        );
                      }),
                )
              ],
            )),
      ),
    );
  }
}
