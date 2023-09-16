import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_rank/authentication/login.dart';
import 'package:green_rank/authentication/sign_up.dart';
import 'package:green_rank/authentication/username.dart';
import 'package:velocity_x/velocity_x.dart';

class LoginSignUp extends StatefulWidget {
  const LoginSignUp({Key? key}) : super(key: key);

  @override
  State<LoginSignUp> createState() => _LoginSignUpState();
}

class _LoginSignUpState extends State<LoginSignUp> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Green Rank", style: TextStyle(color: Colors.white, fontFamily: "lato_bold"),),
          centerTitle: true,
          backgroundColor: Color(0xFF80CBC4),
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: InkWell(
                      onTap: ()
                      {
                        Get.to(LogIn());
                      },
                      child: Container(
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFF80CBC4).withOpacity(0.7),
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            width: 1.5,
                            color: const Color(0xFF80CBC4),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "Log In",
                            style: TextStyle(
                              fontSize: 28,
                              color: Color(0xFF388E3C),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  20.widthBox,
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: InkWell(
                      onTap: ()
                      {
                        Get.to(const Username());
                      },
                      child: Container(
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFF80CBC4).withOpacity(0.7),
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            width: 1.5,
                            color: const Color(0xFF80CBC4),
                          ),
                        ),
                        child: const Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                            children: <Widget>[
                              Text(
                                "New User?",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 28,
                                  color: Color(0xFF388E3C),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              40.heightBox,
              const Text(
                "Compete, Score, and Climb the Green Leaderboard!",
                style: TextStyle(
                  color: Color(0xFF00695C),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
