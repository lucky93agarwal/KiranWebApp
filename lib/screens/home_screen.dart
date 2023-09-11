import 'package:algolia/algolia.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';
import 'package:kiranapp/config/algolia_config.dart';
import 'package:kiranapp/controllers/app_controller.dart';
import 'package:kiranapp/design/app_colors.dart';
import 'package:kiranapp/model/user_data.dart';
import 'package:kiranapp/screens/auth/login.dart';
import 'package:kiranapp/screens/chat_screen_widget.dart';
import 'package:kiranapp/screens/mobile_home_screen.dart';
import 'package:kiranapp/screens/widgets/create_channel.dart';
import 'package:kiranapp/screens/widgets/create_group.dart';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiranapp/services/send_notification.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../services/service_functions.dart';
import 'one_on_one_chat_screen.dart';
import 'dart:html' as html;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  // bool _switchValue = false;
  final box = GetStorage();
  final _firestore = FirebaseFirestore.instance;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (kIsWeb) {
    } else {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }

    await FirebaseMessaging.instance.getToken().then((value) async {
      // print(value);
      await _firestore.collection('users').doc(box.read('id')).update({
        'notificationToken': value,
      });
    });
  }

  @override
  void initState() {
    super.initState();
    firebaseOnMessage();
    // ServicesFunctions().removeDeletedMyGroups();
  }

  void firebaseOnMessage() async {
    FirebaseMessaging.onMessage.listen((message) async {
      if (message != null) {
        final title = message.notification!.title;
        final body = message.notification!.body;
        int result = await audioPlayer.play(
          'https://firebasestorage.googleapis.com/v0/b/chat-app-502c1.appspot.com/o/assets%2Fnotification_sound.mp3?alt=media&token=83ae0779-e0e8-412d-bbf4-fa91bfce0030',
        );
        if (result == 1) {
          // success
        }
        Get.snackbar(
          title!,
          body!,
          duration: const Duration(
            seconds: 2,
          ),
          colorText: Colors.white,
          maxWidth: 350.w,
        );
      }
    });
  }

  void onlineOffline() {
    html.window.onFocus.listen((event) async {
      // do something
      _firestore.collection('users').doc(box.read('id')).update({
        'status': 'Online',
        // 'isLogged': false,
      });
    });

    html.window.onBlur.listen((event) async {
      // do something
      _firestore.collection('users').doc(box.read('id')).update({
        'status': DateFormat.jm().format(DateTime.now()),
        // 'isLogged': false,
      });
    });

    html.window.onSuspend.listen((event) async {
      // do something
      _firestore.collection('users').doc(box.read('id')).update({
        'status': DateFormat.jm().format(DateTime.now()),
        // 'isLogged': false,
      });
    });
    html.window.onAbort.listen((event) async {
      // do something
      _firestore.collection('users').doc(box.read('id')).update({
        'status': DateFormat.jm().format(DateTime.now()),
        // 'isLogged': false,
      });
    });
    html.window.onPageHide.listen((event) async {
      // do something
      _firestore.collection('users').doc(box.read('id')).update({
        'status': DateFormat.jm().format(DateTime.now()),
        // 'isLogged': false,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    onlineOffline();
    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
          print("Enter press");
        }
      },
      child: Scaffold(
        body: Row(
          children: [
            kIsWeb ? const SideBarWidget() : const MobileChatsScreen(),
            kIsWeb
                ? GetBuilder<AppControllers>(builder: (controller) {
                    return controller.currentGroupId != null
                        ? controller.currentGroupType == 'chat'
                    // signle chat
                            ? OneOnOneChatScreen(
                                groupId: controller.currentGroupId!,
                                userName: controller.currentUserName!,
                              )
                    // group chat
                            : ChatScreenWidget(
                                groupId: controller.currentGroupId!,
                              )
                        : Expanded(
                            flex: 3,
                            child: Container(
                              color: Palette.appColor,
                            ),
                          );
                  })
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}

class SideBarWidget extends StatefulWidget {
  const SideBarWidget({Key? key}) : super(key: key);

  @override
  State<SideBarWidget> createState() => _SideBarWidgetState();
}

class _SideBarWidgetState extends State<SideBarWidget> {
  int currentIndex = 0;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final box = GetStorage();
  String? searchKey;
  Stream<QuerySnapshot>? streamQuery;
  AppControllers appcontroller = Get.put(AppControllers());

  final Algolia _algoliaApp = AlgoliaApplication.algolia;
  String? _searchTerm;

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("groups").query(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Scaffold(
        body: Container(
          color: Palette.secondColor,
          child: Column(
            children: [
              Row(
                children: [

                  // logout icon
                  Container(
                      margin: const EdgeInsets.all(8.0),
                      child: /*PopupMenuButton<String>(
                      color: Colors.transparent,
                      elevation: 0.0,
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        PopupMenuItem(
                          enabled: false, // DISABLED THIS ITEM
                          child: GlassmorphicContainer(
                            borderRadius: 20,
                            blur: 5,
                            padding: const EdgeInsets.all(40),
                            alignment: Alignment.bottomCenter,
                            border: 0,
                            linearGradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF1b242b).withOpacity(0.7),
                                const Color(0xFF1b242b).withOpacity(0.7),
                              ],
                              stops: const [
                                0.1,
                                1,
                              ],
                            ),
                            borderGradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                //for border..........................................................
                                const Color(0xFF1b242b).withOpacity(0.5),
                                const Color((0xFF1b242b)).withOpacity(0.5),
                              ],
                            ),
                            height: 50.h,
                            width: 200.w,
                            child: Column(
                              children: [
                                // Flexible(
                                //   child: ListTile(
                                //     onTap: () {
                                //       Navigator.push(
                                //         context,
                                //         MaterialPageRoute(
                                //           builder: (_) => const NewScreen(),
                                //         ),
                                //       );
                                //     },
                                //     shape: const StadiumBorder(),
                                //     leading: const Icon(
                                //       Icons.settings_outlined,
                                //       color: Colors.white,
                                //     ),
                                //     title: const Text(
                                //       'Settings',
                                //       style: TextStyle(
                                //         color: Colors.white,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                Flexible(
                                  child: ListTile(
                                    onTap: () async {
                                      _firestore
                                          .collection('users')
                                          .doc(box.read('id'))
                                          .update({
                                        'status': DateFormat.jm()
                                            .format(DateTime.now()),
                                        // 'isLogged': false,
                                      });
                                      _auth.signOut();
                                      box.erase();
                                      Get.offAll(const LoginScreen());
                                    },
                                    shape: const StadiumBorder(),
                                    leading: const Icon(
                                      Icons.logout,
                                      color: Colors.white,
                                    ),
                                    title: const Text(
                                      'Logout',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.menu,
                          color: Colors.white,
                        ),
                      ),
                    )*/
                          IconButton(
                        onPressed: () async {
                          _firestore
                              .collection('users')
                              .doc(box.read('id'))
                              .update({
                            'status': DateFormat.jm().format(DateTime.now()),
                            // 'isLogged': false,
                          });
                          _auth.signOut();
                          box.erase();
                          Get.offAll(const LoginScreen());
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                      )),
                  // search bar
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 4.0,
                      ),
                      // color: Palette.searchTextFieldColor,
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        onChanged: (searchText) {
                          setState(() {
                            _searchTerm = searchText;
                          });
                        },
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
                  )
                ],
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
                            itemExtent: 90.h,
                            shrinkWrap: true,
                            itemBuilder: ((context, index) {
                              return StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('groupChats')
                                      .doc(box.read('id'))
                                      .collection('myGroups')
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
                                    return snapshot.data!.exists
                                        ? Container(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 2,
                                              horizontal: 3,
                                            ),
                                            child: GetBuilder<AppControllers>(
                                                builder: (controller) {
                                              return ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                child: ElevatedButton(
                                                  style: ButtonStyle(
                                                    padding:
                                                        MaterialStateProperty
                                                            .all(EdgeInsets
                                                                .zero),
                                                    backgroundColor: controller
                                                                .currentIndex ==
                                                            index
                                                        ? MaterialStateProperty
                                                            .all(
                                                            Palette.mainColor,
                                                          )
                                                        : MaterialStateProperty
                                                            .all(
                                                            Colors.transparent,
                                                          ),
                                                  ),
                                                  onPressed: () {
                                                    Get.find<AppControllers>()
                                                        .setCurrentIndex(index);
                                                    Get.find<AppControllers>()
                                                        .setCurrentGroupId(
                                                      id: currSearchStuff[index]
                                                          .data['id'],
                                                      type:
                                                          currSearchStuff[index]
                                                              .data['type'],
                                                    );

                                                    if (currSearchStuff[index]
                                                            .data['type'] ==
                                                        'chat') {
                                                      Get.find<AppControllers>()
                                                          .setCurrentUserName(
                                                              name: data![
                                                                  'username']);
                                                    }
                                                    Get.find<AppControllers>()
                                                        .textFieldClear();
                                                    Get.find<AppControllers>()
                                                        .setInputFocus();
                                                  },
                                                  child: ListTile(
                                                    leading: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.yellow,
                                                      radius: 25.0,
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                            Palette.appColor,
                                                        radius: 23.0,
                                                        child: currSearchStuff[
                                                                            index]
                                                                        .data[
                                                                    'type'] ==
                                                                'group'
                                                            ? const Icon(
                                                                Icons.groups,
                                                              )
                                                            : currSearchStuff[index]
                                                                            .data[
                                                                        'type'] ==
                                                                    'chat'
                                                                ? const Icon(
                                                                    Icons
                                                                        .person,
                                                                  )
                                                                : const Icon(
                                                                    Icons
                                                                        .announcement,
                                                                  ),
                                                      ),
                                                    ),
                                                    title: Text(
                                                      currSearchStuff[index]
                                                                      .data[
                                                                  'type'] ==
                                                              'chat'
                                                          ? data!['username']
                                                          : currSearchStuff[
                                                                      index]
                                                                  .data[
                                                              'groupName'],
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 17.0,
                                                      ),
                                                    ),
                                                    subtitle: StreamBuilder<
                                                            QuerySnapshot>(
                                                        stream: _firestore
                                                            .collection(
                                                                'groups')
                                                            .doc(
                                                                currSearchStuff[
                                                                        index]
                                                                    .data['id'])
                                                            .collection(
                                                                'groupMessages')
                                                            .orderBy(
                                                              'time',
                                                              descending: false,
                                                            )
                                                            .snapshots(),
                                                        builder: (context,
                                                            snapshotData) {
                                                          if (snapshotData
                                                              .hasError) {
                                                            return const Text(
                                                                'Something went wrong');
                                                          }

                                                          if (!snapshotData
                                                              .hasData) {
                                                            return const Text(
                                                                'Loading');
                                                          }

                                                          return Text(
                                                            snapshotData
                                                                    .data!
                                                                    .docs
                                                                    .isEmpty
                                                                ? 'New Chat'
                                                                : snapshotData
                                                                        .data!
                                                                        .docs
                                                                        .last[
                                                                    'message'],
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              color: Colors
                                                                  .white54,
                                                              fontSize: 15.0,
                                                            ),
                                                          );
                                                        }),
                                                  ),
                                                ),
                                              );
                                            }),
                                          )
                                        : const SizedBox();
                                  });
                            }),
                          );
                        })
                    : StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('groupChats')
                            .doc(box.read('id'))
                            .collection('myGroups')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Something went wrong');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          List groups = [];
                          List groupData = [];

                          snapshot.data!.docs.forEach((doc) {
                            // print(doc["message"]);
                            groups.add(doc.id);
                            groupData.add(doc.data());
                          });
                          return ListView.builder(
                            itemCount: groups.length,
                            itemExtent: 90.h,
                            shrinkWrap: true,
                            itemBuilder: ((context, index) {
                              return StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('groups')
                                      .doc(groups[index])
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<
                                              DocumentSnapshot<
                                                  Map<String, dynamic>>>
                                          snapshot) {
                                    if (!snapshot.hasData) {
                                      return const SizedBox();
                                    }
                                    final data = snapshot.data!.data();
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 2,
                                        horizontal: 3,
                                      ),
                                      child: GetBuilder<AppControllers>(
                                          builder: (controller) {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                              padding:
                                                  MaterialStateProperty.all(
                                                      EdgeInsets.zero),
                                              backgroundColor: controller
                                                          .currentIndex ==
                                                      index
                                                  ? MaterialStateProperty.all(
                                                      Palette.mainColor,
                                                    )
                                                  : MaterialStateProperty.all(
                                                      Colors.transparent,
                                                    ),
                                            ),
                                            onPressed: () {
                                              appcontroller.clearMessageReply();
                                              Get.find<AppControllers>()
                                                  .setCurrentIndex(index);
                                              Get.find<AppControllers>()
                                                  .setCurrentGroupId(
                                                id: groups[index],
                                                type: data!['type'],
                                              );

                                              if (data['type'] == 'chat') {
                                                Get.find<AppControllers>()
                                                    .setCurrentUserName(
                                                        name: groupData[index]
                                                            ['username']);
                                              }
                                              Get.find<AppControllers>()
                                                  .textFieldClear();
                                              Get.find<AppControllers>()
                                                  .setInputFocus();
                                            },
                                            child: ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor: Colors.yellow,
                                                radius: 25.0,
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                      Palette.appColor,
                                                  radius: 23.0,
                                                  child: data!['type'] ==
                                                          'group'
                                                      ? const Icon(
                                                          Icons.groups,
                                                        )
                                                      : data['type'] == 'chat'
                                                          ? const Icon(
                                                              Icons.person,
                                                            )
                                                          : const Icon(
                                                              Icons
                                                                  .announcement,
                                                            ),
                                                ),
                                              ),
                                              title: Text(
                                                data['type'] == 'chat'
                                                    ? groupData[index]
                                                        ['username']
                                                    : data['groupName'],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17.0,
                                                ),
                                              ),
                                              subtitle: StreamBuilder<
                                                      QuerySnapshot>(
                                                  stream: _firestore
                                                      .collection('groups')
                                                      .doc(data['id'])
                                                      .collection(
                                                          'groupMessages')
                                                      .orderBy(
                                                        'time',
                                                        descending: false,
                                                      )
                                                      .snapshots(),
                                                  builder:
                                                      (BuildContext context,
                                                          AsyncSnapshot<
                                                                  QuerySnapshot>
                                                              snapshotData) {
                                                    if (snapshotData.hasError) {
                                                      return const Text(
                                                          'Something went wrong');
                                                    }

                                                    if (!snapshotData.hasData) {
                                                      return const Text(
                                                          'Loading');
                                                    }

                                                    return Text(
                                                      snapshotData.data!.docs
                                                              .isEmpty
                                                          ? 'New Chat'
                                                          : snapshotData
                                                              .data!
                                                              .docs
                                                              .last['message'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: Colors.white54,
                                                        fontSize: 15.0,
                                                      ),
                                                    );
                                                  }),
                                              trailing: StreamBuilder<
                                                      QuerySnapshot>(
                                                  stream: _firestore
                                                      .collection('groups')
                                                      .doc(data['id'])
                                                      .collection(
                                                          'groupMessages')
                                                      .snapshots(),
                                                  builder:
                                                      (BuildContext context,
                                                          AsyncSnapshot<
                                                                  QuerySnapshot>
                                                              snapshotData) {
                                                    if (snapshotData.hasError) {
                                                      return const Text(
                                                          'Something went wrong');
                                                    }

                                                    if (!snapshotData.hasData) {
                                                      return const Text(
                                                          'Loading');
                                                    }

                                                    int count = 0;

                                                    for (var msgData
                                                        in snapshotData
                                                            .data!.docs) {
                                                      if (!msgData['seenBy']
                                                          .contains(
                                                              box.read('id'))) {
                                                        count++;
                                                      }
                                                    }
                                                    return count == 0
                                                        ? const SizedBox()
                                                        : Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10.0),
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              child: Text(
                                                                count
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                              radius: 20.0,
                                                            ),
                                                          );
                                                  }),
                                            ),
                                          ),
                                        );
                                      }),
                                    );
                                  });
                            }),
                          );
                        }),
              )
            ],
          ),
        ),
        floatingActionButton:
            box.read('isAdmin') == true ? _getFloat() : const SizedBox(),
      ),
    );
  }
}

Widget _getFloat() {
  return SpeedDial(
    animatedIcon: AnimatedIcons.menu_close,
    animatedIconTheme: const IconThemeData(size: 22),
    backgroundColor: Palette.appColor,
    visible: true,
    curve: Curves.bounceIn,
    overlayColor: Colors.transparent,
    children: [
      // FAB 1  Create Group
      SpeedDialChild(
        child: const Icon(
          Icons.group_add_outlined,
          color: Colors.white,
        ),
        backgroundColor: Palette.appColor,
        onTap: () {
          Get.dialog(
            const Center(
              child: CreateGroupDialog(),
            ),
          );
        },
        label: 'Create Group',
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontSize: 16.0,
        ),
        labelBackgroundColor: Palette.appColor,
      ),
      // FAB 2  Create Announcement Channel
      SpeedDialChild(
        child: const Icon(
          Icons.announcement,
          color: Colors.white,
        ),
        backgroundColor: Palette.appColor,
        onTap: () {
          Get.dialog(
            const Center(
              child: CreateChannelWidget(),
            ),
          );
        },
        label: 'Create Announcement Channel',
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontSize: 16.0,
        ),
        labelBackgroundColor: Palette.appColor,
      )
    ],
  );
}
