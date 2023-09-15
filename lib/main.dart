import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:green_rank/authentication/username.dart';
import 'package:green_rank/utils/firebase_variables.dart';
import 'home_screen/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // It will set the color of Notification bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Color(0xFF81C784), statusBarIconBrightness: Brightness.dark),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var is_login = false;
  checkUser() async
  {
    auth.authStateChanges().listen((User? user)
    {
      if(user == null && mounted)
      {
        setState(() {
          is_login = false;
        });
      }
      else
      {
        setState(() {
          is_login = true;
        });
      }
    });
  }
  @override
  void initState() {
    super.initState();
    checkUser();
  }
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(fontFamily: "lato"),
      debugShowCheckedModeBanner: false,
      home: is_login == true ? const HomeScreen() : const Username(),  // Change the name of file
      title: "Green Rank",
    );
  }
}