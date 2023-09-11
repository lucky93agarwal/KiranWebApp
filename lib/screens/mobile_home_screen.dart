import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:kiranapp/screens/chat_screen_widget.dart';
import 'package:kiranapp/screens/widgets/create_channel.dart';
import '../controllers/app_controller.dart';
import '../design/app_colors.dart';
import 'auth/login.dart';
import 'mobile_chat_screen.dart';
import 'mobile_one_on_one_chat_screen.dart';
import 'widgets/create_group.dart';

class MobileChatsScreen extends StatefulWidget {
  const MobileChatsScreen({Key? key}) : super(key: key);

  @override
  State<MobileChatsScreen> createState() => _MobileChatsScreenState();
}

class _MobileChatsScreenState extends State<MobileChatsScreen> {
  int currentIndex = 0;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final box = GetStorage();
  AppControllers appcontroller = Get.put(AppControllers());
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Palette.secondColor,
          elevation: 0.0,
          toolbarHeight: 0.4.h,
        ),
        body: Container(
          color: Palette.secondColor,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8.0),
                    child: PopupMenuButton<String>(
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
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
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
                  )
                ],
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('groupChats')
                        .doc(box.read('id'))
                        .collection('myGroups')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                        itemExtent: 10.5.h,
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
                                      borderRadius: BorderRadius.circular(20.0),
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all(
                                              EdgeInsets.zero),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                            Colors.transparent,
                                          ),
                                        ),
                                        onPressed: () {
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
                                          if (controller.currentGroupId !=
                                                  null &&
                                              controller.currentGroupType ==
                                                  'chat') {
                                            Get.to(
                                              MobileOneOnOneChatScreen(
                                                groupId: groups[index],
                                                userName:
                                                    controller.currentUserName!,
                                              ),
                                            );
                                          } else {
                                            Get.to(
                                              MobileChatScreen(
                                                groupId: groups[index],
                                              ),
                                            );
                                          }
                                        },
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.yellow,
                                            radius: 25.0,
                                            child: CircleAvatar(
                                              backgroundColor: Palette.appColor,
                                              radius: 23.0,
                                              child: data!['type'] == 'group'
                                                  ? const Icon(
                                                      Icons.groups,
                                                    )
                                                  : data['type'] == 'chat'
                                                      ? const Icon(
                                                          Icons.person,
                                                        )
                                                      : const Icon(
                                                          Icons.announcement,
                                                        ),
                                            ),
                                          ),
                                          title: Text(
                                            data['type'] == 'chat'
                                                ? groupData[index]['username']
                                                : data['groupName'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 17.0,
                                            ),
                                          ),
                                          subtitle: Text(
                                            data['message'],
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                          // trailing: Column(
                                          //   children: [
                                          //     SizedBox(
                                          //       height: 3.h,
                                          //       width: 3.w,
                                          //       child: Row(
                                          //         mainAxisAlignment:
                                          //             MainAxisAlignment.center,
                                          //         children: [
                                          //           Icon(
                                          //             Icons.done_all,
                                          //             color: controller
                                          //                         .currentIndex ==
                                          //                     index
                                          //                 ? Colors.white
                                          //                 : Palette.mainColor,
                                          //             size: 18.0,
                                          //           ),
                                          //           const SizedBox(
                                          //             width: 5.0,
                                          //           ),
                                          //           const Text(
                                          //             'Thu',
                                          //             style: TextStyle(
                                          //               color: Colors.white,
                                          //             ),
                                          //           )
                                          //         ],
                                          //       ),
                                          //     ),
                                          //     SizedBox(
                                          //       height: 1.h,
                                          //       width: 50,
                                          //     ),
                                          //   ],
                                          // ),
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
      // FAB 1
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
      // FAB 2
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
