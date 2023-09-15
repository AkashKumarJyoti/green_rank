import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:green_rank/home_screen/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const ProfileScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Color btnColor = const Color(0xFF81C784);
  var nameController = TextEditingController();
  File? image;
  String? url;
  String? imageUrl;
  var userData;

  @override
  void initState() {
    // TODO: implement initState
    userData = widget.data;
    imageUrl = widget.data['imageUrl'];
    url = widget.data['imageUrl'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: 'Profile'.text.fontFamily("lato_bold").size(24.0).make(),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            actions: [
              TextButton(
                  onPressed: () async {
                    await profileUpdate(url!);
                    Get.offAll(() => const HomeScreen());
                  },
                  child: const Text(
                    "Save",
                    style:
                        TextStyle(color: Colors.white, fontFamily: "lato_bold"),
                  ))
            ],
          ),
          backgroundColor: const Color(0xFF80CBC4),
          body: Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                10.heightBox,
                CircleAvatar(
                  radius: 80,
                  backgroundColor: btnColor,
                  child: Stack(children: <Widget>[
                    ClipOval(
                      child: SizedBox(
                        height: 160,
                        width: 160,
                        child: url!.isEmpty
                            ? Image.asset('images/ic_user.png')
                            : CachedNetworkImage(
                                imageUrl: url!,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: InkWell(
                        onTap: () {
                          _showImagePickerOptions(context);
                        },
                        child: const CircleAvatar(
                            child: Icon(Icons.camera_alt_rounded,
                                color: Colors.white)),
                      ),
                    )
                  ]),
                ),
                ListTile(
                  leading: const Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(text: userData['name']),
                    style: const TextStyle(color: Colors.grey, fontSize: 20),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFF00E5FF), width: 2.0)),
                      label: "Name".text.make(),
                      labelStyle: const TextStyle(
                          fontFamily: "lato_bold", color: Colors.white),
                    ),
                  ),
                  subtitle: "This name is visible to your friends"
                      .text
                      .fontFamily("lato_bold")
                      .white
                      .make(),
                ),
                ListTile(
                  leading: const Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Icon(Icons.call, color: Colors.white),
                  ),
                  title: TextFormField(
                    controller: TextEditingController(text: userData['phone']),
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.grey, fontSize: 20),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: btnColor, width: 2.0)),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFF00E5FF), width: 2.0)),
                      label: "Phone".text.make(),
                      labelStyle: const TextStyle(
                          fontFamily: "lato_bold", color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Take a photo'),
              onTap: () async {
                await pickImage(ImageSource.camera);
                Navigator.pop(context); // Close the BottomSheet
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.0),
              child: Divider(color: Colors.grey, height: 2),
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Choose from gallery'),
              onTap: () async {
                await pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // It will pick Image from gallery or camera
  Future pickImage(ImageSource source) async {
    try {
      final images = await ImagePicker().pickImage(source: source);
      if (images == null) {
        return;
      }
      final imageTemporary = File(images.path);
      setState(() {
        image = imageTemporary;
      });
      await uploadImage();
    } on PlatformException catch (e) {
      print("Failed to pick image: $e");
    }
  }

  // It will upload the image to Firebase storage
  Future uploadImage() async {
    if (image != null) {
      String str = DateTime.now().toString();
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child('images');
      Reference referenceImageToUpload = referenceDirImages.child(str);
      try {
        await referenceImageToUpload.putFile(File(image!.path));
        imageUrl = await referenceImageToUpload.getDownloadURL();
        print(imageUrl);
        setState(() {
          url = imageUrl!;
        });
        print(url);
      } catch (error) {
        print(error);
      }
    } else {
      return;
    }
  }

  // It will update the imageUrl in firestore
  profileUpdate(String url) async {
    print(url);
    final user = FirebaseAuth.instance.currentUser;
    String? userUID = user?.uid;
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('User').doc(userUID);
    await userDocRef.update({'imageUrl': url});
    VxToast.show(context, msg: "Profile updated successfully");
  }
}
