import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void logout() {
    _auth.signOut();
  }

  Future<FirebaseUser> getCurrentUser() async {
    return await _auth.currentUser();
  }

  bool checkUserExist() {
    if (_auth.currentUser() == null) {
      print("no user");
      return false;
    } else {
      print(_auth.currentUser().toString());
      return true;
    }
  }


  Future<FirebaseUser> handleEmailSignIn(String email, String password, context) async {
    final FirebaseUser user = (await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    ))
        .user;

    return user;
  }

}
