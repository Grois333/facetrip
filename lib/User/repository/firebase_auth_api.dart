import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthAPI {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User?> signIn() async {
    try {
      GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount == null) return null;

      GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;
      User? user = (await _auth.signInWithCredential(
        GoogleAuthProvider.credential(
          idToken: gSA.idToken,
          accessToken: gSA.accessToken,
        ),
      ))
          .user;

      return user;
    } catch (e) {
      print("Sign-in error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await googleSignIn.signOut();
    await _auth.signOut();
    print("All sessions cleared.");
  }
}

