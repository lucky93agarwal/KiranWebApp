import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kiranapp/screens/admin/admin_home.dart';
import 'package:kiranapp/screens/admin/auth/admin_login.dart';
import 'package:kiranapp/screens/home_screen.dart';
import 'package:kiranapp/wrapper.dart';
import 'package:lifecycle/lifecycle.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  // window.document.onContextMenu.listen((evt) => evt.preventDefault());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1440, 1024),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Kiran App',
          debugShowCheckedModeBanner: false,
          navigatorObservers: [defaultLifecycleObserver],
          theme: ThemeData.light().copyWith(
              scrollbarTheme: const ScrollbarThemeData().copyWith(
            thumbColor: MaterialStateProperty.all(Colors.white),
          )),
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => const Wrapper()),
            GetPage(name: '/home', page: () => const HomeScreen()),
            GetPage(name: '/adminLogin', page: () => const AdminLoginPage()),
            GetPage(name: '/adminHome', page: () => const AdminHomePage()),
          ],
        );
      },
    );
  }
}
