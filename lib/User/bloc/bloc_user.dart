import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facetrip/Place/repository/firebase_storage_repository.dart';
import 'package:facetrip/User/repository/cloud_firestore_api.dart';
import 'package:facetrip/User/ui/widgets/profile_place.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
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

  // Firestore collection stream
  Stream<QuerySnapshot> placesListStream = FirebaseFirestore.instance
      .collection(CloudFirestoreAPI().PLACES)
      .snapshots();

  Stream<QuerySnapshot> get placesStream => placesListStream;

  //List<ProfilePlace> buildPlaces(List<DocumentSnapshot> placesListSnapshot) => _cloudFirestoreRepository.buildPlaces(placesListSnapshot);


  List<ProfilePlace> buildPlaces(List<DocumentSnapshot> placesListSnapshot) {
    return placesListSnapshot.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      // Convert Firebase user to custom UserModel
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      userModel.User currentUserModel = mapFirebaseUserToUserModel(firebaseUser!);

      return ProfilePlace(
        Place(
          key: Key(doc.id), // Use doc.id as key
          id: doc.id,
          name: data['name'],
          description: data['description'],
          urlImage: data['urlImage'],
          likes: data['likes'],
          userOwner: currentUserModel, // Pass the mapped custom UserModel
        ),
      );
    }).toList();
  }

   Stream<QuerySnapshot> myPlacesListStream(String uid) =>
    FirebaseFirestore.instance.collection(CloudFirestoreAPI().PLACES).where(
        "userOwner", isEqualTo: FirebaseFirestore.instance.doc(
        "${CloudFirestoreAPI().USERS}/${uid}")).snapshots();

  // Convert firebase_auth.User to your custom UserModel
  userModel.User mapFirebaseUserToUserModel(User firebaseUser) {
    return userModel.User(
      key: Key(firebaseUser.uid),
      uid: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'Unknown',  // Use default value if null
      email: firebaseUser.email ?? 'No Email',
      photoURL: firebaseUser.photoURL ?? '',
      myPlaces: [],
      myFavoritePlaces: [],
    );
  }

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
