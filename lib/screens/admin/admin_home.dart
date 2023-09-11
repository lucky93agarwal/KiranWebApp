import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:kiranapp/design/app_colors.dart';
import 'package:kiranapp/model/admin_menu.dart';
import 'package:kiranapp/screens/admin/auth/admin_login.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final _auth = FirebaseAuth.instance;
  final box = GetStorage();
  final _firestore = FirebaseFirestore.instance;
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Home'),
        elevation: 0.0,
        backgroundColor: Palette.appColor,
        leading: Container(
          margin: const EdgeInsets.all(8.0),
          child: PopupMenuButton<String>(
            color: Colors.transparent,
            elevation: 0.0,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
                  height: 60.h,
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
                            Get.offAll(
                              const AdminLoginPage(),
                            );
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
      ),
      backgroundColor: Palette.appColor,
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 0.1.h,
                  color: Colors.black,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: menuData.length,
                   
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        onTap: () {
                          setState(() {
                            currentIndex = index;
                          });
                        },
                        hoverColor: Colors.yellow[100]!.withOpacity(0.1),
                        leading: menuData[index].icon,
                        tileColor: currentIndex == index
                            ? const Color(0xffFFD124).withOpacity(0.5)
                            : Colors.transparent,
                        title: Text(
                          menuData[index].title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 0.2,
            color: Colors.black,
          ),
          currentIndex == 0
              ? UsersSide(
                  firestore: _firestore,
                  isAdminFilter: currentIndex,
                )
              : currentIndex == 1
          ? UsersSide(
                  firestore: _firestore,
                  isAdminFilter: currentIndex,
                )
          : UsersSide(
            firestore: _firestore,
            isAdminFilter: currentIndex,
          ),
        ],
      ),
    );
  }
}


class UsersSide extends StatefulWidget {
  const UsersSide({
    Key? key,
    required FirebaseFirestore firestore,
    required this.isAdminFilter,
  })  : _firestore = firestore,
        super(key: key);

  final FirebaseFirestore _firestore;
  // ignore: prefer_typing_uninitialized_variables
  final int isAdminFilter;

  @override
  State<UsersSide> createState() => _UsersSideState();
}

class _UsersSideState extends State<UsersSide> {


  String currentPermission = '';
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            height: 0.2,
            color: Colors.black,
          ),
          // tabbar
          Row(
            children: [
              SizedBox(
                width: 80.w,
                child: const Center(
                  child: SelectableText(
                    'Users',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(),
              ),
              Container(
                width: 200.w,
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
            ],
          ),
          // heading
          Container(
            color: Colors.black,
            height: 50.h,
            child: Row(
              children: [
                SizedBox(
                  width: 80.w,
                  child: const Center(
                    child: SelectableText(
                      'User Info',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                SizedBox(
                  width: 100.w,
                  child: const Center(
                    child: SelectableText(
                      'Permission',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: widget.isAdminFilter ==1
                    ? widget._firestore
                        .collection("users")
                        .where(
                          'isAdmin',
                          isEqualTo: true,
                        ).snapshots()
                    :  widget.isAdminFilter ==0
                    ? widget._firestore.collection("users").snapshots()
                    :widget._firestore
                    .collection("users")
                    .where(
                  'searchIndex',
                  arrayContains: "Office Staff",
                ).snapshots(),
                builder: (context, snapshotData) {
                  if (snapshotData.hasError) {
                    return const Text('Something went wrong');
                  }
                  if (!snapshotData.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshotData.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  List<Widget> numberTiles = [];

                  for (var info in snapshotData.data!.docs) {
                    // print(doc["message"]);

                    numberTiles.add(
                      ListTile(
                        onTap: () {
                          if(info['searchIndex'].contains("Office Staff")){
                            currentPermission = 'Office Staff';
                          }
                          else
                          if (info['isAdmin']) {
                            currentPermission = 'Admin';
                          } else {
                            currentPermission = 'Not Admin';
                          }
                          Get.dialog(
                            Center(
                              child: PermissionsDialog(
                                currentPermission: currentPermission,
                                userId: info['id'],
                              ),
                            ),
                          );
                        },
                        hoverColor: Colors.yellow[100]!.withOpacity(0.1),
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
                        trailing:

                        info['searchIndex'].contains("Office Staff")==true
                            ?
                        const Text(
                          'Ofice Staff',
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        )
                            :
                        info['isAdmin'] == true
                            ? const Text(
                          'Admin',
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        )
                            : const Text(
                          'Not Admin',
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        )


                       ,
                      ),
                    );
                  }
                  return ListView(
                    scrollDirection: Axis.vertical,
                    children: numberTiles,
                  );
                }),
          )
        ],
      ),
    );
  }
}

class PermissionsDialog extends StatefulWidget {
  const PermissionsDialog({
    Key? key,
    required this.currentPermission,
    required this.userId,
  }) : super(key: key);
  final String currentPermission;
  final String userId;
  @override
  State<PermissionsDialog> createState() => _PermissionsDialogState();
}

class _PermissionsDialogState extends State<PermissionsDialog> {
  List permissions = [
    'Admin',
    'Not Admin',
    'Office Staff',
  ];

  String currentPermission = '';
  final _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentPermission = widget.currentPermission;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        height: 400.h,
        width: 300.w,
        color: Palette.secondColor,
        child: Scaffold(
          backgroundColor: Palette.secondColor,
          appBar: AppBar(
            backgroundColor: Palette.mainColor.withOpacity(0.5),
            title: const Text('Change Users Permission'),
            elevation: 0.0,
            automaticallyImplyLeading: false,
          ),
          body: ListView.builder(
              itemCount: permissions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    setState(() {
                      currentPermission = permissions[index];
                    });
                  },
                  tileColor: currentPermission == permissions[index]
                      ? Colors.blue
                      : Colors.transparent,
                  leading: Icon(
                    index == 0
                        ? Icons.verified_user
                        : Icons.supervised_user_circle,
                    color: Colors.white,
                  ),
                  title: Text(
                    permissions[index],
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                );
              }),
          bottomNavigationBar: Container(
            color: Colors.transparent,
            height: 70.h,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: isLoading ? const Center(child:  CircularProgressIndicator())  : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                // ignore: deprecated_member_use
                child: TextButton(
                  onPressed: ()async{
                    setState(() {
                    isLoading = true;
                    });
                    if (currentPermission == 'Not Admin') {
                      await _firestore
                          .collection('users')
                          .doc(widget.userId)
                          .update({
                        'isAdmin': false,
                      });
                      await _firestore
                          .collection('users')
                          .doc(widget.userId)
                          .update({
                        'searchIndex': FieldValue.arrayRemove(["Office Staff"]),
                      });
                      Get.back();
                    } else if (currentPermission == 'Admin') {
                      await _firestore
                          .collection('users')
                          .doc(widget.userId)
                          .update({
                        'isAdmin': true,
                      });
                      await _firestore
                          .collection('users')
                          .doc(widget.userId)
                          .update({
                        'searchIndex': FieldValue.arrayRemove(["Office Staff"]),
                      });
                      Get.back();
                    } else if (currentPermission == 'Office Staff') {
                      await _firestore
                          .collection('users')
                          .doc(widget.userId)
                          .update({
                        'searchIndex': FieldValue.arrayUnion(["Office Staff"]),
                      });
                      Get.back();
                    }else{
                      Navigator.pop(context);
                    }
                    setState(() {
                      isLoading = false;
                    });
                  },
                child: Text(
                  'Ok',
                  style: TextStyle(
                    color: Palette.appColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ),
               /* child: FlatButton(
                  color: Colors.white,
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    if (currentPermission == 'Not Admin') {
                      await _firestore
                          .collection('users')
                          .doc(widget.userId)
                          .update({
                        'isAdmin': false,
                      });
                      await _firestore
                          .collection('users')
                          .doc(widget.userId)
                          .update({
                        'searchIndex': FieldValue.arrayRemove(["Office Staff"]),
                      });
                      Get.back();
                    } else if (currentPermission == 'Admin') {
                      await _firestore
                          .collection('users')
                          .doc(widget.userId)
                          .update({
                        'isAdmin': true,
                      });
                      await _firestore
                          .collection('users')
                          .doc(widget.userId)
                          .update({
                        'searchIndex': FieldValue.arrayRemove(["Office Staff"]),
                      });
                      Get.back();
                    } else if (currentPermission == 'Office Staff') {
                      await _firestore
                          .collection('users')
                          .doc(widget.userId)
                          .update({
                        'searchIndex': FieldValue.arrayUnion(["Office Staff"]),
                      });
                      Get.back();
                    }else{
                      Navigator.pop(context);
                    }
                    setState(() {
                      isLoading = false;
                    });
                  },
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    'Ok',
                    style: TextStyle(
                      color: Palette.appColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),*/
              ),
            ),
          ),
        ),
      ),
    );
  }
}
