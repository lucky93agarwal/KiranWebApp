// ignore_for_file: prefer_typing_uninitialized_variables, unused_local_variable
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kiranapp/screens/admin/admin_home.dart';
import '../../../design/app_colors.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({Key? key}) : super(key: key);

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  TextEditingController phoneNumberCont = TextEditingController();
  var phoneNumber;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final box = GetStorage();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.secondColor,
      body: Center(
        child: Container(
          height: 670.h,
          width: 700.w,
          padding: EdgeInsets.symmetric(horizontal: 150.w, vertical: 50.h),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 250.h,
                  width: 320.w,
                  child: Image.network(
                      'https://firebasestorage.googleapis.com/v0/b/chat-app-502c1.appspot.com/o/assets%2Fkiran_logo.jpg?alt=media&token=69636d69-2810-41af-820c-9e4e8d3de269'),
                ),
                const SizedBox(
                  child: SelectableText(
                    'Kiran Super Admin Login',
                    style: TextStyle(
                      fontSize: 25.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 3.h,
                ),
                TextFormField(
                  controller: email,
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Email required !';
                    }
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(
                        Icons.email_outlined,
                        color: Colors.white60,
                      ),
                    ),
                    hintText: 'Email',
                    hintStyle: const TextStyle(
                      color: Colors.white60,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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
                  height: 3.h,
                ),
                TextFormField(
                  controller: password,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Password required !';
                    }
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(
                        Icons.lock_outline,
                        color: Colors.white60,
                      ),
                    ),
                    hintText: 'Password',
                    hintStyle: const TextStyle(
                      color: Colors.white60,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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
                  height: 3.h,
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
                            color: Palette.mainColor.withOpacity(0.7),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });
                                try {
                                  await _auth
                                      .signInWithEmailAndPassword(
                                          email: email.text,
                                          password: password.text)
                                      .then(
                                    (value) {
                                      box.write(
                                        'adminId',
                                        value.user!.uid.toString(),
                                      );
                                      box.write('isAdminLoggedIn', true);
                                      Get.to(const AdminHomePage());
                                    },
                                  );
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'user-not-found') {
                                    // print('No user found for that email.');
                                    Get.snackbar(
                                      'Message',
                                      'No user found for that email.',
                                      padding: const EdgeInsets.all(8.0),
                                      colorText: Colors.white,
                                      maxWidth: 400.w,
                                    );
                                  } else if (e.code == 'wrong-password') {
                                    Get.snackbar(
                                      'Message',
                                      'Wrong password provided for that user.',
                                      padding: const EdgeInsets.all(8.0),
                                      colorText: Colors.white,
                                      maxWidth: 400.w,
                                    );
                                    // print('Wrong password provided for that user.');
                                  }
                                }
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                            padding: const EdgeInsets.all(5),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
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
