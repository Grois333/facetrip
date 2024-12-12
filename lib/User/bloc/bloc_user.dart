import 'dart:io';

import 'package:facetrip/Place/repository/firebase_storage_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/User/model/user.dart' as userModel;
import 'package:facetrip/User/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:facetrip/User/repository/cloud_firestore_repository.dart';
import '../../Place/model/place.dart';


class UserBloc implements Bloc {

  final _auth_repository = AuthRepository();

  // Stream - Firebase
  // Use `authStateChanges()` instead of `onAuthStateChanged`
  Stream<User?> streamFirebase = FirebaseAuth.instance.authStateChanges();
  Stream<User?> get authStatus => streamFirebase;

  Future<User?> currentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user;
  }

  // Casos de uso
  // 1. SignIn a la aplicación Google
  Future<User> signIn() {
    return _auth_repository.signInFirebase();
  }

   //2. Registrar usuario en base de datos
  final _cloudFirestoreRepository = CloudFirestoreRepository();
  void updateUserData(userModel.User user) => _cloudFirestoreRepository.updateUserDataFirestore(user);
  Future<void> updatePlaceData(Place place) => _cloudFirestoreRepository.updatePlaceData(place);

  final _firebaseStorageRepository = FirebaseStorageRepository();
  Future<UploadTask> uploadFile(String path, File image){
    // path, directory where to save
    // image, real file to store
    return _firebaseStorageRepository.uploadFile(path, image);
  }

  signOut() {
    _auth_repository.signOut();
  }

  @override
  void dispose() {
    // Dispose logic if needed
  }
}
