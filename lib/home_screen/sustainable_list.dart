import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SustainableActionsListView extends StatefulWidget {
  final String userId;
  final Function()? onPointsUpdated;

  const SustainableActionsListView(
      {required this.userId, this.onPointsUpdated});

  @override
  _SustainableActionsListViewState createState() =>
      _SustainableActionsListViewState();
}

class _SustainableActionsListViewState
    extends State<SustainableActionsListView> {
  Map<String, bool> actionCheckboxState =
      {}; // Map to store the checkbox state for each action

  int currentUserPoints = 0; // Store the user's current points

  @override
  void initState() {
    super.initState();
    fetchUserPoints(); // It will fetch the user's current points from Firestore
  }

  void fetchUserPoints() async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .doc(widget.userId)
          .get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        final points = userData['points'] ?? 0;
        setState(() {
          currentUserPoints = points;
        });
      }
    } catch (e) {
      print('Error fetching user points: $e');
    }
  }

  void updateUserPoints() async {
    // It update the user points in Firestore
    try {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(widget.userId)
          .update({
        'points': currentUserPoints,
      });
    } catch (e) {
      print('Error updating user points: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('actions').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No sustainable actions found.'));
        } else {
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              String actionName = data['name'] ?? 'Name not available';
              int actionPoints = data['points'] ?? 0;
              bool isChecked = actionCheckboxState[actionName] ?? false;

              return CheckboxListTile(
                title: Text(actionName),
                subtitle: Row(
                  children: [
                    Text('Points: $actionPoints'),
                    Icon(
                      Icons.monetization_on,
                      color: Colors.yellow.shade700,
                      size: 18,
                    ),
                  ],
                ),
                value: isChecked,
                onChanged: (bool? newValue) {
                  setState(() {
                    actionCheckboxState[actionName] = newValue ?? false;
                    if (newValue == true) {
                      currentUserPoints +=
                          actionPoints; // We will add the points when checkbox is checked
                    } else {
                      currentUserPoints -=
                          actionPoints; // We will subtract points when checkbox is unchecked
                    }
                    if (currentUserPoints < 0) {
                      currentUserPoints = 0;
                    }
                    updateUserPoints();
                    widget
                        .onPointsUpdated!(); // User point will be updated in firebase
                  });
                },
              );
            }).toList(),
          );
        }
      },
    );
  }
}
