import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kiranapp/screens/widgets/model/chat_user_data.dart';
import '../../config/algolia_config.dart';
import '../../design/app_colors.dart';

class GroupUsersDialog extends StatefulWidget {
  const GroupUsersDialog({
    Key? key,
    required this.groupId,
  }) : super(key: key);
  final String groupId;
  @override
  State<GroupUsersDialog> createState() => _GroupUsersDialogState();
}

class _GroupUsersDialogState extends State<GroupUsersDialog> {
  final _firestore = FirebaseFirestore.instance;
  final box = GetStorage();
  bool isLoading = false;

  List<ChatUserData> users = [];

  Future createChat({
    required String id,
    required String chatName,
  }) async {
    final chatId = DateTime.now().millisecondsSinceEpoch;

    List<String> splitList = chatName.split(" ");
    List<String> indexList = [];

    for (int i = 0; i < splitList.length; i++) {
      for (var y = 0; y < splitList[i].length; y++) {
        indexList.add(splitList[i].substring(0, y).toLowerCase());
      }
    }

    await _firestore.collection("groups").doc(chatId.toString()).set({
      'id': chatId.toString(),
      'groupName': chatName,
      'isOff': false,
      'url': null,
      'admins': [id],
      'message': 'New chat',
      'messageIndex': 0,
      'type': 'chat',
      'searchIndex': indexList,
    });

    await _firestore
        .collection("groupChats")
        .doc(users[0].id)
        .collection("myGroups")
        .doc(chatId.toString())
        .set({
      'id': chatId.toString(),
      'username': users[1].username,
    });
    await _firestore
        .collection("groups")
        .doc(chatId.toString())
        .collection('groupMembers')
        .doc(users[0].id)
        .set({
      'id': users[0].id,
      'phone': users[0].phoneNumber,
      'isAdmin': users[0].id != id ? false : true,
    });

    await _firestore
        .collection("groupChats")
        .doc(users[1].id)
        .collection("myGroups")
        .doc(chatId.toString())
        .set({
      'id': chatId.toString(),
      'username': users[0].username,
    });
    await _firestore
        .collection("groups")
        .doc(chatId.toString())
        .collection('groupMembers')
        .doc(users[1].id)
        .set({
      'id': users[1].id,
      'phone': users[1].phoneNumber,
      'isAdmin': users[1].id != id ? false : true,
    });
  }

  final Algolia _algoliaApp = AlgoliaApplication.algolia;
  String? _searchTerm;

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("users").query(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

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
              title:
                  Text(box.read('isGroup') ? 'Group Users' : 'Channel Users'),
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
                    onChanged: (value) {
                      setState(() {
                        _searchTerm = value;
                      });
                    },
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
                  child: _searchTerm != null && _searchTerm!.trim() != ''
                      ? StreamBuilder<List<AlgoliaObjectSnapshot>>(
                          stream: Stream.fromFuture(_operation(_searchTerm!)),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Text(
                                "Start Typing",
                                style: TextStyle(color: Colors.grey),
                              );
                            }
                            List<AlgoliaObjectSnapshot>? currSearchStuff =
                                snapshot.data;
                            return ListView.builder(
                              itemCount: currSearchStuff!.length,
                              // itemExtent: 8.5.h,
                              shrinkWrap: true,
                              itemBuilder: ((context, index) {
                                return StreamBuilder(
                                    stream: _firestore
                                        .collection("groups")
                                        .doc(widget.groupId)
                                        .collection('groupMembers')
                                        .doc(currSearchStuff[index].data['id'])
                                        .snapshots(),
                                    builder: (context,
                                        AsyncSnapshot<
                                                DocumentSnapshot<
                                                    Map<String, dynamic>>>
                                            snapshot) {
                                      if (!snapshot.hasData) {
                                        return const SizedBox();
                                      }
                                      if (snapshot.hasError) {
                                        return const SizedBox();
                                      }
                                      final data = snapshot.data!.data();
                                      return ListTile(
                                        leading: CircleAvatar(
                                          child: Text(
                                            currSearchStuff[index]
                                                .data['username'][0]
                                                .toUpperCase(),
                                          ),
                                        ),
                                        title: Text(
                                          currSearchStuff[index]
                                              .data['username'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        subtitle: Text(
                                          currSearchStuff[index]
                                              .data['phoneNumber'],
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        // ignore: deprecated_member_use
                                        trailing: FlatButton(
                                          onPressed: () async {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            final String id = box.read('id');

                                            await _firestore
                                                .collection("users")
                                                .doc(id)
                                                .get()
                                                .then((value) async {
                                              users.add(
                                                ChatUserData(
                                                  id: currSearchStuff[index]
                                                      .data['id'],
                                                  username:
                                                      currSearchStuff[index]
                                                          .data['username'],
                                                  phoneNumber:
                                                      currSearchStuff[index]
                                                          .data['phoneNumber'],
                                                ),
                                              );
                                              users.add(
                                                ChatUserData(
                                                  id: value['id'],
                                                  username: value['username'],
                                                  phoneNumber:
                                                      value['phoneNumber'],
                                                ),
                                              );
                                              // create two way chat
                                              await createChat(
                                                  id: id,
                                                  chatName:
                                                      '${currSearchStuff[index].data['username']} ${value['username']}');
                                            });
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                            Get.snackbar(
                                              'Message',
                                              'chat successfully started!',
                                              maxWidth: 350.w,
                                              colorText: Colors.white,
                                            );
                                            setState(() {
                                              isLoading = false;
                                            });
                                          },
                                          color: Palette.mainColor
                                              .withOpacity(0.5),
                                          child: const Text(
                                            'Start Chat',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                              }),
                            );
                          })
                      : StreamBuilder<QuerySnapshot>(
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

                            List<Widget> numberTiles = [];

                            for (var data in snapshotData.data!.docs) {
                              // print(doc["message"]);
                              if (data['phone'] != phoneNumber) {
                                numberTiles.add(
                                  FutureBuilder<DocumentSnapshot>(
                                      future: _firestore
                                          .collection("users")
                                          .doc(data.id)
                                          .get(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<DocumentSnapshot>
                                              snapshot) {
                                        if (snapshot.hasError) {
                                          return const Text(
                                              "Something went wrong");
                                        }

                                        if (snapshot.hasData &&
                                            !snapshot.data!.exists) {
                                          return const Text(
                                              "Document does not exist");
                                        }

                                        if (!snapshot.hasData) {
                                          return const SizedBox();
                                        }

                                        Map<String, dynamic> info =
                                            snapshot.data!.data()
                                                as Map<String, dynamic>;

                                        // if (snapshot.connectionState ==
                                        //     ConnectionState.done) {
                                        //   Map<String, dynamic> info = snapshot.data!
                                        //       .data() as Map<String, dynamic>;
                                        //   return Text(
                                        //       "Full Name: ${data['full_name']} ${data['last_name']}");
                                        // }
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
                                          // ignore: deprecated_member_use
                                          trailing: FlatButton(
                                            onPressed: () async {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              final String id = box.read('id');

                                              await _firestore
                                                  .collection("users")
                                                  .doc(id)
                                                  .get()
                                                  .then((value) async {
                                                users.add(
                                                  ChatUserData(
                                                    id: info['id'],
                                                    username: info['username'],
                                                    phoneNumber:
                                                        info['phoneNumber'],
                                                  ),
                                                );
                                                users.add(
                                                  ChatUserData(
                                                    id: value['id'],
                                                    username: value['username'],
                                                    phoneNumber:
                                                        value['phoneNumber'],
                                                  ),
                                                );
                                                // create two way chat
                                                await createChat(
                                                    id: id,
                                                    chatName:
                                                        '${info['username']} ${value['username']}');
                                              });
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                              Get.snackbar(
                                                'Message',
                                                'chat successfully started!',
                                                maxWidth: 350.w,
                                                colorText: Colors.white,
                                              );
                                              setState(() {
                                                isLoading = false;
                                              });
                                            },
                                            color: Palette.mainColor
                                                .withOpacity(0.5),
                                            child: const Text(
                                              'Start Chat',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                );
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
