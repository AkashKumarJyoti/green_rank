import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_rank/Profile_Screen/profile_screen.dart';
import 'package:green_rank/authentication/username.dart';
import 'package:velocity_x/velocity_x.dart';

import '../utils/firebase_variables.dart';

Widget drawer(Map<String, dynamic> data) {
  String username = data['name'];
  String imageUrl = data['imageUrl'];
  Color btnColor = const Color(0xFFBA68C8);
  return Drawer(
      backgroundColor: const Color(0xFF4DB6AC),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(25))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.arrow_back_ios_new_outlined,
                      color: Colors.white)
                  .onTap(() {
                Get.back();
              }),
              title: "Settings".text.semiBold.size(20).white.make(),
            ),
            20.heightBox,
            CircleAvatar(
              radius: 45,
              backgroundColor: btnColor,
              child: ClipOval(
                child: SizedBox(
                  height: 160,
                  width: 160,
                  child: imageUrl.isEmpty
                      ? Image.asset('images/ic_user.png')
                      : CachedNetworkImage(
                          imageUrl: imageUrl,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      value: downloadProgress.progress),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              // child: imageUrl.isEmpty ? Image.asset('images/ic_user.png') : Image.network(imageUrl)
            ),
            10.heightBox,
            username.text.semiBold.white.size(20).make(),
            20.heightBox,
            Divider(color: btnColor, height: 1),
            ListTile(
              leading: const Icon(Icons.key_rounded, color: Colors.white),
              title: "Account".text.semiBold.size(16).white.make(),
              onTap: () => Get.to(() => ProfileScreen(data: data)),
            ),
            10.heightBox,
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: "Logout".text.semiBold.white.size(16).make(),
              onTap: () async {
                await auth.signOut();
                Get.offAll(() => const Username());
              },
            )
          ],
        ),
      ));
}
