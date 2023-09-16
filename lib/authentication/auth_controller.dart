import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
import '../home_screen/home_screen.dart';
import '../utils/firebase_variables.dart';

class AuthController extends GetxController
{
  var usernameController = TextEditingController();
  var phoneController = TextEditingController();
  late String otpController;
  var is_fetching = false.obs;
  var isOtpSent = false.obs;
  var str = "Verify OTP".obs;
  late final PhoneVerificationCompleted phoneVerificationCompleted;
  late final PhoneVerificationFailed phoneVerificationFailed;
  late final PhoneCodeSent phoneCodeSent;
  String verificationID = '';

  // It will send the OTP
  sendOtp() async
  {
    phoneVerificationCompleted = (PhoneAuthCredential credential) async {
      await auth.signInWithCredential(credential);    // auth = FirebaseAuth.instance -> declared in utils directory
    };
    phoneVerificationFailed = (FirebaseAuthException e) {
      if (e.code == 'invalid-phone-number') {
        print('The provided phone number is not valid.');
      }
    };
    phoneCodeSent = (String verificationId, int? resendToken) {
      verificationID = verificationId;
      isOtpSent.value = true;
      is_fetching.value = false;
    };
    try
    {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+91${phoneController.text}",
        verificationCompleted: phoneVerificationCompleted,
        verificationFailed: phoneVerificationFailed,
        codeSent: phoneCodeSent,
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    }
    catch (e)
    {
      print(e.toString());
    }
  }

  // It will verify the otp
  verifyOtpnewUser(context) async
  {
    String otp = otpController;
    try
    {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(verificationId: verificationID, smsCode: otp);
      final User? user = (await auth.signInWithCredential(phoneAuthCredential)).user;  // auth = FirebaseAuth.instance
      if(user != null)
      {
        DocumentReference store = FirebaseFirestore.instance.collection("User").doc(user.uid);
        await store.set(
            {
              'id': user.uid,
              'name': usernameController.text.toString(),
              'phone': phoneController.text.toString(),
              'imageUrl': "",
              'points': 0   // To show in LeaderBoard
            }, SetOptions(merge: true)
        );
        VxToast.show(context, msg: "Logged In");
        Get.offAll(() => const HomeScreen(), transition: Transition.downToUp);
      }
    }
    catch (e)
    {
      VxToast.show(context, msg: e.toString());
    }
  }

  verifyOtpoldUser(context) async
  {
    String otp = otpController;
    try
    {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(verificationId: verificationID, smsCode: otp);
      final User? user = (await auth.signInWithCredential(phoneAuthCredential)).user;  // auth = FirebaseAuth.instance
      if(user != null)
      {
        DocumentReference store1 = FirebaseFirestore.instance.collection("UserRecord").doc(phoneController.text.toString());
        await store1.set(
            {
              'phone': phoneController.text.toString()
            }, SetOptions(merge: true)
        );
        VxToast.show(context, msg: "Logged In");
        Get.offAll(() => const HomeScreen(), transition: Transition.downToUp);
      }
    }
    catch (e)
    {
      VxToast.show(context, msg: e.toString());
    }
  }
}