import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthAPI {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User?> signIn() async {
    // Attempt to sign in using GoogleSignIn
    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    
    // If the sign-in was canceled, return null or handle it as needed
    if (googleSignInAccount == null) {
      // Handle sign-in cancelation, e.g., show a message, return null, etc.
      return null;
    }

    // Authenticate with Firebase using the GoogleSignIn account's authentication tokens
    GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;

    // Sign in with Firebase and retrieve the user
    User user = (await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: gSA.idToken, accessToken: gSA.accessToken))).user!;

    return user;
  }

  signOut() async {
    await _auth.signOut().then((onValue) => print("Sesión cerrada"));
    googleSignIn.signOut();
    print("Sesiones cerradas");
  }
  
}
