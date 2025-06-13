import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  String? uid;
  DatabaseService({this.uid});

  CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");
  CollectionReference adminCollection =
      FirebaseFirestore.instance.collection("admin");

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

  // New method to submit message to admin collection
  Future submitAdminMessage(
      String title, String message, String userName, String userEmail) async {
    return await adminCollection.add({
      "title": title,
      "message": message,
      "userName": userName,
      "userEmail": userEmail,
      "uid": uid,
      "timestamp": FieldValue.serverTimestamp(),
      "status": "pending", // You can use this for tracking message status
    });
  }

  // Optional: Method to get all admin messages (for admin panel)
  Future getAdminMessages() async {
    QuerySnapshot snapshot =
        await adminCollection.orderBy("timestamp", descending: true).get();
    return snapshot;
  }

  // Optional: Method to get messages by specific user
  Future getUserAdminMessages(String userUid) async {
    QuerySnapshot snapshot = await adminCollection
        .where("uid", isEqualTo: userUid)
        .orderBy("timestamp", descending: true)
        .get();
    return snapshot;
  }

  // Optional: Method to update message status (for admin use)
  Future updateMessageStatus(String messageId, String status) async {
    return await adminCollection.doc(messageId).update({
      "status": status,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }
}
