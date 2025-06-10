import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  String? uid;

  DatabaseService({this.uid});

  CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");

  CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  Future updateUserWithEmailAndPassword(
      String fullName, String email, String password) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "uid": uid,
      "profilePic": "",
    });
  }

  Future getuserdata(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }
}
