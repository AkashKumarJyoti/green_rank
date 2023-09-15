import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:green_rank/home_screen/drawer.dart';
import 'package:green_rank/home_screen/sustainable_list.dart';
import 'package:velocity_x/velocity_x.dart';

import '../utils/firebase_variables.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? data;
  String? UserId = auth.currentUser?.uid;
  String imageUrl = "";

  @override
  void initState() {
    // TODO: implement initState
    getUserData(auth.currentUser!.uid);
    fetchAndDisplayLeaderboard();
    super.initState();
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // This data is for ProfileScreen and Drawer. Also to show image of user on home screen
  void getUserData(String userId) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('User').doc(userId).get();
      if (userSnapshot.exists) {
        setState(() {
          data = userSnapshot.data() as Map<String, dynamic>;
        });
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving user data: $e');
      return null;
    }
    setState(() {
      imageUrl = data?['imageUrl'];
    });
  }

  List<QueryDocumentSnapshot> leaderboardData = []; // To show LeaderBoard
  Future<void> fetchAndDisplayLeaderboard() async {
    try {
      final QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .orderBy('points', descending: true)
          .get();

      setState(() {
        leaderboardData = usersSnapshot.docs;
        rank = leaderboardData.indexWhere((doc) => doc.id == UserId) +
            1; // To determine the rank of the current user
      });
    } catch (e) {
      print('Error fetching leaderboard: $e');
    }
  }

  int? rank; // To show the rank of the user
  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
            title: const Text("Green Rank",
                style: TextStyle(color: Colors.white, fontFamily: "lato_bold")),
            elevation: 0.0,
            centerTitle: true,
            backgroundColor: const Color(0xFF80CBC4),
            leading: IconButton(
              onPressed: () {
                scaffoldKey.currentState?.openDrawer();
              },
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
            )),
        drawer: data != null ? drawer(data!) : null,
        body: Column(
          children: [
            Container(
                height: h / 4,
                width: w,
                decoration: const BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(14.0)),
                  color: Color(0xFF80CBC4),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                        radius: 45,
                        backgroundColor: Color(0xFFBA68C8),
                        child: ClipOval(
                            child: SizedBox(
                                height: 90,
                                width: 90,
                                child: imageUrl.isEmpty
                                    ? Image.asset('images/ic_user.png')
                                    : CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        progressIndicatorBuilder: (context, url,
                                                downloadProgress) =>
                                            CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress),
                                        fit: BoxFit.cover,
                                      )))),
                    data == null
                        ? const CircularProgressIndicator()
                        : Text(
                            "${data?['name']}",
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontFamily: "lato_bold",
                                fontSize: 28),
                          ),
                    12.heightBox,
                    rank == null
                        ? const CircularProgressIndicator()
                        : Text(
                            "Green Rank $rank",
                            style: const TextStyle(
                                fontFamily: "lato_black",
                                color: Color(0xFF388E3C),
                                fontSize: 36),
                          )
                  ],
                )),
            Expanded(
                child: ListView.builder(
              itemCount: leaderboardData.length,
              itemBuilder: (context, index) {
                final userData =
                    leaderboardData[index].data() as Map<String, dynamic>;
                final userName = userData['name'];
                final userPoints = userData['points'];
                final userImageUrl = userData['imageUrl'];
                final userRank = index + 1; // Calculate the user's rank

                return Card(
                  elevation: 3.0,
                  color:
                      index == rank! - 1 ? Colors.green.shade400 : Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                        // CircleAvatar to show the rank in the center of listTile
                        backgroundColor: Colors.white,
                        child: Center(
                            child: Text(
                          "#$userRank",
                          style: const TextStyle(color: Colors.grey),
                        )) // Show rank as leading
                        ),
                    title: Text(userName),
                    subtitle: Row(
                      children: [
                        Text('Points: $userPoints'),
                        Icon(
                          Icons.monetization_on,
                          color: Colors.yellow.shade700,
                          size: 14,
                        ),
                      ],
                    ),
                    trailing: CircleAvatar(
                      child: userImageUrl.isEmpty
                          ? Image.asset('images/ic_user.png')
                          : ClipOval(
                              child: SizedBox(
                                height: 90,
                                width: 90,
                                child: CachedNetworkImage(
                                  imageUrl: userImageUrl,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                    ),
                  ),
                );
              },
            )),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () {
            _showSustainableList();
          },
          child: Icon(Icons.monetization_on,
              color: Colors.yellow.shade700, size: 50),
        ),
      ),
    );
  }

  void _showSustainableList() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sustainable Actions List',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SustainableActionsListView(
                  userId: data?['id'],
                  onPointsUpdated: () {
                    fetchAndDisplayLeaderboard(); // To rebuild the leaderboard. It will be updated when checkbox is clicked
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
