import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../Intro_page/intro_page.dart';
import '../home_screen/home_screen.dart';
import '../utils/firebase_variables.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Color btnColor = const Color(0xFF80CBC4);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Welcome(context);
    checkUser();
  }

  var is_login = false;

  checkUser() async {
    auth.authStateChanges().listen((User? user) {
      if (user == null && mounted) {
        setState(() {
          is_login = false;
        });
      } else {
        setState(() {
          is_login = true;
        });
      }
    });
  }

  Future<void> Welcome(BuildContext context) async {
    Timer(const Duration(seconds: 4), () async {
      if (is_login == true) {
        Get.offAll(const HomeScreen());
      } else {
        Get.offAll(const LoginSignUp());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
          body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              btnColor.withOpacity(0.2),
              btnColor.withOpacity(0.4),
              btnColor.withOpacity(0.6),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 55,
                backgroundColor: Color(0xFF009688),
                child: ClipOval(
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: Image.asset('images/tree.jpg', fit: BoxFit.cover),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 18.0),
                child: Text("Green Rank",
                    style: TextStyle(
                      color: Color(0xFF388E3C),
                      fontSize: 35,
                      fontWeight: FontWeight.w600,
                    )),
              )
            ],
          ),
        ),
      )),
    );
  }
}
