import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:velocity_x/velocity_x.dart';
import 'auth_controller.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String s = "Let's Re-Connect";
  final _formKey = GlobalKey<FormState>();
  var controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    // Default Pin theme of OTP
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: Color(0xFF4CAF50).withOpacity(0.3),
        border: Border.all(color: Color(0xFF00E676)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    // Focused Pin theme of OTP
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color(0xFF00E676), width: 2.0),
      borderRadius: BorderRadius.circular(8),
    );

    // Submitted theme of OTP
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(width: 2.5, color: const Color(0xFF1B5E20).withOpacity(0.3) ),
        color: const Color(0xFF4CAF50).withOpacity(0.6),
      ),
    );
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: "Let's Connect".text.size(22).black.fontFamily("lato_black").make(),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: Column(
          children: <Widget>[
            10.heightBox,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    15.heightBox,
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length != 10) {
                          return 'Enter valid Phone number';
                        }
                        return null; // Return null if the value is valid
                      },
                      controller: controller.phoneController,
                      keyboardType: TextInputType.number,
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
                          labelText: "Phone Number",
                          labelStyle: const TextStyle(
                            color: Vx.gray600,
                            fontWeight: FontWeight.bold,
                          ),
                          prefixIcon: const Icon(Icons.phone_android_rounded, color: Color(0xFF13165F),),
                          prefixText: "+91 ",
                          hintText: "eg. 12345678990"
                      ),
                    ),
                  ],
                ),
              ),
            ),
            10.heightBox,
            Obx(() => Visibility(
              visible: controller.isOtpSent.value == false,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: "We will send an SMS with a confirmation code on your phone number".text.size(16).make(),
              ),
            ),),

            // OTP field will be shown when OTP is processed
            Obx(() => Visibility(
                visible: controller.isOtpSent.value,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: "Enter the OTP".text.size(18).bold.make(),
                    ),
                    Pinput(
                      length: 6,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: focusedPinTheme,
                      submittedPinTheme: submittedPinTheme,
                      showCursor: true,
                      onCompleted: (pin) => controller.otpController = pin,
                    ),
                  ],
                )
            ),),
            const Spacer(),
            SizedBox(
              width: context.screenWidth - 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.all(16.0)
                ),
                onPressed: () async {
                  if(_formKey.currentState!.validate())
                  {
                    var userExist = await checkUserExists(controller.phoneController.value.text);
                    {
                      if(userExist)
                      {
                        if (controller.isOtpSent.value == false) {
                          controller.is_fetching.value = true;  // To show the CircularProgressIndicator
                          await controller.sendOtp();  // controller.is_fetching.value will be false after it executed
                          setState(() {
                            s = controller.str.value;
                          });
                        }
                        else {
                          controller.is_fetching.value = true;
                          await controller.verifyOtpoldUser(context);
                        }
                      }
                      else
                      {
                          VxToast.show(context, msg: "User don't exists, please do sign up", bgColor: Colors.red, textColor: Colors.white, textSize: 15);
                          setState(()
                          {
                            controller.phoneController.clear();
                          });
                      }
                    }
                  }
                },
                child: s.text.semiBold.size(20).make(),
              ),
            ),
            20.heightBox,
            // It is shown while OTP verification or while sendOTP
            Obx(() => Visibility(
                visible: controller.is_fetching.value,
                child: const SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(color: Color(0xFFA5D6A7))
                )
            ),),
            40.heightBox
          ],
        ),
      ),
    );
  }

  // Check user exists
  Future<bool> checkUserExists(String number) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('UserRecord')
          .where('phone', isEqualTo: number)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking username: $e');
      return false;
    }
  }
}
