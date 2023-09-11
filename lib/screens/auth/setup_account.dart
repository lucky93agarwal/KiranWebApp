import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kiranapp/screens/home_screen.dart';
import 'package:kiranapp/screens/widgets/terms_and_conditions.dart';
import '../../design/app_colors.dart';

class SetupAccount extends StatefulWidget {
  const SetupAccount({Key? key}) : super(key: key);

  @override
  State<SetupAccount> createState() => _SetupAccountState();
}

class _SetupAccountState extends State<SetupAccount> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final box = GetStorage();
  final _firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  bool hasAccepted = false;

  final email = TextEditingController();
  final username = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.secondColor,
      body: Form(
        key: _formKey,
        child: Center(
          child: Container(
            height: 660.h,
            width: kIsWeb ? 700.w : double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: Palette.appColor,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  child: Text(
                    'Complete Account Setup',
                    style: TextStyle(
                      fontSize: 40.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                TextFormField(
                  controller: email,
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is Required !';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Icon(
                        Icons.email,
                        color: Colors.white60,
                      ),
                    ),
                    hintText: 'Email',
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
                SizedBox(
                  height: 5.h,
                ),
                TextFormField(
                  controller: username,
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username Required !';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Icon(
                        Icons.person,
                        color: Colors.white60,
                      ),
                    ),
                    hintText: 'Username',
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
                SizedBox(
                  height: 2.h,
                ),
                Row(
                  children: [
                    Checkbox(
                      value: hasAccepted,
                      fillColor: MaterialStateProperty.all<Color>(Colors.white),
                      checkColor: Colors.blue,
                      onChanged: (value) {
                        setState(() {
                          hasAccepted = value!;
                        });
                      },
                    ),
                    SizedBox(
                      width: 1.h,
                    ),
                    InkWell(
                      onTap: () {
                        Get.dialog(
                          const Center(child: TermsAndConditions()),
                        );
                      },
                      child: const Text(
                        'Accept our terms and conditons.',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 2.h,
                ),
                ButtonTheme(
                  minWidth: 450.w,
                  height: 60.h,
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          // ignore: deprecated_member_use
                          child: FlatButton(
                            color: Colors.white,
                            onPressed: () async {
                              print(box.read('id'));
                              if (_formKey.currentState!.validate()) {
                                if (hasAccepted) {
                                  setState(() {
                                    isLoading = true;
                                  });

                                  String userName = username.text;

                                  List<String> splitList = userName.split(" ");
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
                                      .collection('users')
                                      .doc(box.read('id'))
                                      .set({
                                    'username': username.text,
                                    'id': box.read('id'),
                                    'email': email.text,
                                    'phoneNumber': box.read('phone'),
                                    'isSelected': false,
                                    'signup_date': DateTime.now(),
                                    'isAdmin': false,
                                    'hasAcceptedTerms': hasAccepted,
                                    'searchIndex': indexList,
                                  });

                                  _firestore
                                      .collection('users')
                                      .doc(box.read('id'))
                                      .get()
                                      .then((data) {
                                    box.write('isAdmin', data['isAdmin']);
                                  });

                                  await _firestore
                                      .collection("groups")
                                      .doc('1649744535608')
                                      .get()
                                      .then((group) async {
                                    if (group.exists) {
                                      await _firestore
                                          .collection("groups")
                                          .doc('1649744535608')
                                          .collection('groupMembers')
                                          .doc(box.read('id'))
                                          .set({
                                        'id': box.read('id'),
                                        'isAdmin': false,
                                        'phone': box.read('phone'),
                                      });
                                      await _firestore
                                          .collection('groupChats')
                                          .doc(
                                            box.read('id'),
                                          )
                                          .collection('myGroups')
                                          .doc('1649744535608')
                                          .set({
                                        'id': '1649744535608',
                                      });
                                    } else {
                                      String groupName = 'Common Group';
                                      List<String> splitList =
                                          groupName.split(" ");
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
                                          .doc('1649744535608')
                                          .set({
                                        'id': '1649744535608',
                                        'groupName': groupName,
                                        'isOff': false,
                                        'url': null,
                                        'admins': [],
                                        'message': 'New group',
                                        'messageIndex': 0,
                                        'type': 'group',
                                        'searchIndex': indexList,
                                      });

                                      await _firestore
                                          .collection("groups")
                                          .doc('1649744535608')
                                          .collection('groupMembers')
                                          .doc(box.read('id'))
                                          .set({
                                        'id': box.read('id'),
                                        'isAdmin': false,
                                        'phone': box.read('phone'),
                                      });
                                      await _firestore
                                          .collection('groupChats')
                                          .doc(
                                            box.read('id'),
                                          )
                                          .collection('myGroups')
                                          .doc('1649744535608')
                                          .set({
                                        'id': '1649744535608',
                                      });
                                    }
                                  });

                                  Get.snackbar(
                                    'Message',
                                    'User successfully added to the common group !',
                                    maxWidth: 400.w,
                                    colorText: Colors.white,
                                  );
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen(),
                                      ),
                                      (route) => false);
                                  setState(() {
                                    isLoading = false;
                                  });
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    'You have to accept them terms and conditons to continue !',
                                    maxWidth: 400.w,
                                    colorText: Colors.white,
                                  );
                                }
                              }
                            },
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              'Complete',
                              style: TextStyle(
                                color: Palette.appColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
}
