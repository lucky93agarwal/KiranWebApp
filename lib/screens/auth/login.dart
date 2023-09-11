import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:kiranapp/design/app_colors.dart';
import 'package:kiranapp/screens/auth/opt.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phoneNumberCont = TextEditingController();
  var phoneNumber;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.secondColor,
      body: Center(
        child: Container(
          height: 660.h,
          width: kIsWeb ? 700.w : double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 150.w),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              kIsWeb
                  ? SizedBox(
                      height: 250.h,
                      width: 320.w,
                      child: Image.asset('kiran_logo.jpg'),
                    )
                  : SizedBox(
                      child: Image.asset('kiran_logo.jpg'),
                    ),
              SizedBox(
                height: 5.h,
              ),
              IntlPhoneField(
                controller: phoneNumberCont,
                validator: (value) =>'Phone number cannot be blank',
                autovalidateMode: AutovalidateMode.disabled,
                style: const TextStyle(
                  color: Colors.white,
                ),
                dropdownIcon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                ),
                dropdownTextStyle: const TextStyle(
                  color: Colors.white,
                ),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Palette.searchTextFieldColor,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  focusColor: Colors.white,
                ),
                initialCountryCode: 'IN',
                onChanged: (phone) {
                  print(phone.completeNumber);
                  setState(() {
                    phoneNumber = phone.completeNumber;
                  });
                },
              ),
              SizedBox(
                height: 3.h,
              ),
              ButtonTheme(
                minWidth: 450.w,
                height: 60.h,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  // ignore: deprecated_member_use
                  child: FlatButton(
                    color: Palette.mainColor.withOpacity(0.7),
                    onPressed: () {
                      if (phoneNumberCont.text.isNotEmpty) {
                        Get.to(
                          OTPScreen(phoneNumber),
                        );
                      }
                    },
                    padding: const EdgeInsets.all(5),
                    child: const Text(
                      'Next',
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
    );
  }
}
