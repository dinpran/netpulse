import 'package:firebase_auth/firebase_auth.dart';
import 'package:netpulse/helper/helper_functions.dart';
import 'package:netpulse/service/database_service.dart';

class AuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future loginUserWithEmailAndPassword(String email, String password) async {
    try {
      User user = (await _auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;
      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future registerUserWithEmailAndPassword(
      String fullName, String email, String password) async {
    try {
      User user = (await _auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;
      if (user != null) {
        await DatabaseService(uid: user.uid)
            .updateUserWithEmailAndPassword(fullName, email, password);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future sigout() async {
    await HelperFunctions.saveUserLoggedInKey(false);
    await HelperFunctions.saveUserNamenKey("");
    await HelperFunctions.saveUserEmailKey("");
    await _auth.signOut();
  }
}
