import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kiranapp/screens/admin/admin_home.dart';
import 'package:kiranapp/screens/auth/login.dart';
import 'package:kiranapp/screens/home_screen.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final box = GetStorage();
  @override
  Widget build(BuildContext context) {
    if (box.read('id') != null && box.read('isAdminLoggedIn') != true) {
      return const HomeScreen();
    } else if (box.read('isAdminLoggedIn') == true) {
      return const AdminHomePage();
    } else {
      return const LoginScreen();
    }
  }
}
