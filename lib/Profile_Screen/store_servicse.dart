import '../utils/firebase_variables.dart';

// It will get the user
class StoreServices {
  static getUser(String id) {
    return firebaseFirestore
        .collection('user')
        .where('id', isEqualTo: id)
        .get();
  }
}