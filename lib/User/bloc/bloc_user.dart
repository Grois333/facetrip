import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/User/model/user.dart' as userModel;
import 'package:facetrip/User/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:facetrip/User/repository/cloud_firestore_repository.dart';


class UserBloc implements Bloc {

  final _auth_repository = AuthRepository();

  // Stream - Firebase
  // Use `authStateChanges()` instead of `onAuthStateChanged`
  Stream<User?> streamFirebase = FirebaseAuth.instance.authStateChanges();
  Stream<User?> get authStatus => streamFirebase;

  // Casos de uso
  // 1. SignIn a la aplicación Google
  Future<User> signIn() {
    return _auth_repository.signInFirebase();
  }

   //2. Registrar usuario en base de datos
  final _cloudFirestoreRepository = CloudFirestoreRepository();
  void updateUserData(userModel.User user) => _cloudFirestoreRepository.updateUserDataFirestore(user);

  signOut() {
    _auth_repository.signOut();
  }

  @override
  void dispose() {
    // Dispose logic if needed
  }
}
