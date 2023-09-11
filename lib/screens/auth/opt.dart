import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kiranapp/screens/auth/setup_account.dart';
import 'package:kiranapp/screens/home_screen.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../design/app_colors.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  OTPScreen(this.phone);
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    /// Focus pinput
    _pinPutFocusNode.requestFocus();
  }
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  String? _verificationCode;
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  final box = GetStorage();
  late ConfirmationResult confirmationResult;
  final _firestore = FirebaseFirestore.instance;

  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: const Color.fromRGBO(43, 46, 66, 1),
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(
      color: const Color.fromRGBO(126, 203, 224, 1),
    ),
  );

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
      borderRadius: BorderRadius.circular(20),
    ),
  );
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final auth = FirebaseAuth.instance;
    if (kIsWeb) {
      confirmationResult = await auth.signInWithPhoneNumber(
        widget.phone,
      );
    } else {
      _verifyPhone();
    }
  }

  @override
  Widget build(BuildContext context) {
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Scaffold(
      key: _scaffoldkey,
      backgroundColor: Palette.secondColor,
      body: Center(
        child: Container(
          height: 660.h,
          width: kIsWeb ? 700.w : double.infinity,
          // padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: Palette.appColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: AppBar(
                  centerTitle: true,
                  title: const Text('Phone number verification'),
                  elevation: 0.0,
                  backgroundColor: Palette.appColor,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    widget.phone,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Pinput(
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  controller: _pinPutController,
                  length: 6,
                  focusNode: _pinPutFocusNode,
                  pinAnimationType: PinAnimationType.fade,
                  onCompleted: (pin) async {
                    try {
                      if (kIsWeb) {
                        await confirmationResult
                            .confirm(pin)
                            .then((value) async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (value.user != null) {
                            box.write('id', value.user!.uid.toString());
                            box.write(
                                'phone', value.user!.phoneNumber.toString());



                            if (value.additionalUserInfo!.isNewUser) {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SetupAccount(),
                                  ),
                                  (route) => false);
                            } else {
                              _firestore
                                  .collection('users')
                                  .doc(value.user!.uid)
                                  .get()
                                  .then((data) {

                                if(data['searchIndex'].contains("Office Staff")){
                                  box.write('Office_Staff', true);
                                }else {
                                  box.write('Office_Staff', false);
                                }
                                box.write('isAdmin', data['isAdmin']);
                              });

                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                  (route) => false);
                              // FirebaseFirestore.instance
                              //     .collection('users')
                              //     .doc(value.user!.uid)
                              //     .get()
                              //     .then((data) {
                              //   if (data['isLoggedIn'] != false ||
                              //       data['isLoggedIn'] == null) {
                              //     FirebaseFirestore.instance
                              //         .collection('users')
                              //         .doc(value.user!.uid)
                              //         .update({
                              //       'isLoggedIn': true,
                              //     });
                              //     Navigator.pushAndRemoveUntil(
                              //         context,
                              //         MaterialPageRoute(
                              //           builder: (context) => const HomeScreen(),
                              //         ),
                              //         (route) => false);
                              //   } else {
                              //     Get.showSnackbar(
                              //       const GetSnackBar(
                              //         message:
                              //             'Only one user can be logged in at a time',
                              //         duration: Duration(seconds: 2),
                              //       ),
                              //     );
                              //   }
                              // });
                            }
                          }
                        });
                      } else {
                        await FirebaseAuth.instance
                            .signInWithCredential(
                          PhoneAuthProvider.credential(
                            verificationId: _verificationCode.toString(),
                            smsCode: pin,
                          ),
                        )
                            .then((value) async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (value.user != null) {
                            box.write('id', value.user!.uid.toString());
                            box.write(
                                'phone', value.user!.phoneNumber.toString());
                            if (value.additionalUserInfo!.isNewUser) {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SetupAccount(),
                                  ),
                                  (route) => false);
                            } else {
                              _firestore
                                  .collection('users')
                                  .doc(value.user!.uid)
                                  .get()
                                  .then((data) {
                                box.write('isAdmin', data['isAdmin']);
                              });

                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                  (route) => false);
                              // FirebaseFirestore.instance
                              //     .collection('users')
                              //     .doc(value.user!.uid)
                              //     .get()
                              //     .then((data) {
                              //   if (data['isLoggedIn'] == false ||
                              //       data['isLoggedIn'] == null) {
                              //     FirebaseFirestore.instance
                              //         .collection('users')
                              //         .doc(value.user!.uid)
                              //         .update({
                              //       'isLoggedIn': true,
                              //     });
                              //     Navigator.pushAndRemoveUntil(
                              //         context,
                              //         MaterialPageRoute(
                              //           builder: (context) => MainPage(),
                              //         ),
                              //         (route) => false);
                              //   } else {
                              //     Get.showSnackbar(
                              //       const GetSnackBar(
                              //         message:
                              //             'Only one user can be logged in at a time',
                              //         duration: Duration(seconds: 2),
                              //       ),
                              //     );
                              //   }
                              // });
                            }
                          }
                        });
                      }
                    } catch (e) {
                      FocusScope.of(context).unfocus();
                      _scaffoldkey.currentState!.showSnackBar(
                          const SnackBar(content: Text('invalid OTP')));
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '${widget.phone}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            if (value.user != null) {
              box.write('id', value.user!.uid.toString());
              box.write('phone', value.user!.phoneNumber.toString());
              await prefs.setString(
                'id',
                value.user!.uid.toString(),
              );
              await prefs.setString(
                'phone',
                value.user!.phoneNumber.toString(),
              );
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SetupAccount(),
                  ),
                  (route) => false);
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String verficationID, int? resendToken) {
          setState(() {
            _verificationCode = verficationID;
          });
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          setState(() {
            _verificationCode = verificationID;
          });
        },
        timeout: Duration(seconds: 120));
  }
}
