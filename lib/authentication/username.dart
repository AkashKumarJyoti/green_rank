import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:green_rank/authentication/auth_controller.dart';
import 'package:green_rank/authentication/sign_up.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:get/get.dart';

class Username extends StatefulWidget {
  const Username({Key? key}) : super(key: key);

  @override
  State<Username> createState() => _UsernameState();
}

class _UsernameState extends State<Username> {
  final _formKey = GlobalKey<FormState>();
  var controller = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: "Let's Connect".text.size(22).black.fontFamily("lato_black").make(),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            10.heightBox,
            Form(
              key: _formKey,
              child: TextFormField(
                validator: (value)
                {
                  if(value!.isEmpty)
                  {
                    return "Please Enter your Username";
                  }
                  return null;
                },
                controller: controller.usernameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                            color: Vx.gray600
                        )
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                          width: 2.5,
                          color: Color(0xFF26A69A)
                      ),
                    ),
                    alignLabelWithHint: true,
                    labelText: "Username",
                    labelStyle: const TextStyle(
                      color: Vx.gray600,
                      fontWeight: FontWeight.bold,
                    ),
                    prefixIcon: const Icon(Icons.phone_android_rounded, color: Color(0xFF13165F),),
                    hintText: "eg. Akash123"
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: context.screenWidth - 40,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.all(16.0)
                  ),
                  onPressed: ()
                  async {
                    if(_formKey.currentState!.validate())
                    {
                      var usernameExist = await checkUsernameExists(controller.usernameController.value.text);
                      if(usernameExist)
                      {
                        VxToast.show(context, msg: "Username already exists", bgColor: Colors.red, textColor: Colors.white, textSize: 15);
                        setState(()
                        {
                          controller.usernameController.clear();
                        });
                      }
                      else
                      {
                        Get.to(() => const VerificationScreen());
                      }
                    }
                  },
                  child: const Text("Continue", style: TextStyle(
                    fontSize: 20,
              ))),
            ),
            60.heightBox,
          ],
        ),
      ),
    );
  }

  // It will check whether the user with that name already exist or not
  Future<bool> checkUsernameExists(String username) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('name', isEqualTo: username)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking username: $e');
      return false;
    }
  }
}
