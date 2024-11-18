import 'package:firebase_auth/firebase_auth.dart';
import 'package:facetrip/User/repository/firebase_auth_api.dart';

class AuthRepository {

  final _firebaseAuthAPI = FirebaseAuthAPI();

  Future<User> signInFirebase() async {
    User? user = await _firebaseAuthAPI.signIn();
    
    if (user == null) {
      throw Exception("Sign-in failed or was canceled");
    }

    return user;
  }
}
