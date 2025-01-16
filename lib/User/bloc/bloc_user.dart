import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facetrip/Place/repository/firebase_storage_repository.dart';
import 'package:facetrip/Place/ui/widgets/card_image.dart';
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

  Stream<userModel.User> get userInfoStream async* {
    // Wait for the current user from FirebaseAuth
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    
    if (firebaseUser != null) {
      yield mapFirebaseUserToUserModel(firebaseUser);  // Yield the mapped user data
    } else {
      // Handle the case when there is no current user (e.g., user is signed out)
      yield userModel.User(
        key: Key('no-user'),
        uid: '',
        name: 'Guest',
        email: 'guest@example.com',
        photoURL: '',
        myPlaces: [],
        myFavoritePlaces: [],
      );
    }
  }


  Future<User?> currentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  // Casos de uso
  // 1. SignIn a la aplicación Google
  Future<User> signIn() async {
    try {
      User user = await _auth_repository.signInFirebase();
      return user;
    } catch (e) {
      print("Sign-in error: $e");
      rethrow;
    }
  }

   //2. Registrar usuario en base de datos
  final _cloudFirestoreRepository = CloudFirestoreRepository();
  void updateUserData(userModel.User user) => _cloudFirestoreRepository.updateUserDataFirestore(user);
  Future<void> updatePlaceData(Place place) => _cloudFirestoreRepository.updatePlaceData(place);

  // Retrieve user data from Firestore
  Future<userModel.User?> getUserData(String uid) async {
    try {
      // Fetch user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection(CloudFirestoreAPI().USERS) // Replace with your collection name
          .doc(uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;

        // Convert `myPlaces` and `myFavoritePlaces` from Firestore to Place objects
        List<Place> myPlaces = (data['myPlaces'] as List<dynamic>? ?? [])
            .map((placeData) {
              final placeMap = placeData as Map<String, dynamic>;
              return Place(
                key: Key(placeMap['id'] ?? ''),
                id: placeMap['id'] ?? '',
                name: placeMap['name'] ?? '',
                description: placeMap['description'] ?? '',
                urlImage: placeMap['urlImage'] ?? '',
                likes: placeMap['likes'] ?? 0,
                liked: placeMap['liked'] ?? false,
                userOwner: userModel.User( 
                  key: Key(uid), // Updated to use your custom User class
                  uid: placeMap['userOwner']['uid'] ?? '',
                  name: placeMap['userOwner']['name'] ?? 'Unknown',
                  email: placeMap['userOwner']['email'] ?? 'No Email',
                  photoURL: placeMap['userOwner']['photoURL'] ?? '',
                  myPlaces: [],  // Empty list or fetch as needed
                  myFavoritePlaces: [],  // Empty list or fetch as needed
                ),
                stars: placeMap['stars'] ?? 0,
              );
            })
            .toList();

        List<Place> myFavoritePlaces = (data['myFavoritePlaces'] as List<dynamic>? ?? [])
            .map((placeData) {
              final placeMap = placeData as Map<String, dynamic>;
              return Place(
                key: Key(placeMap['id'] ?? ''),
                id: placeMap['id'] ?? '',
                name: placeMap['name'] ?? '',
                description: placeMap['description'] ?? '',
                urlImage: placeMap['urlImage'] ?? '',
                likes: placeMap['likes'] ?? 0,
                liked: placeMap['liked'] ?? false,
                userOwner: userModel.User( 
                  key: Key(uid), // Updated to use your custom User class
                  uid: placeMap['userOwner']['uid'] ?? '',
                  name: placeMap['userOwner']['name'] ?? 'Unknown',
                  email: placeMap['userOwner']['email'] ?? 'No Email',
                  photoURL: placeMap['userOwner']['photoURL'] ?? '',
                  myPlaces: [],  // Empty list or fetch as needed
                  myFavoritePlaces: [],  // Empty list or fetch as needed
                ),
                stars: placeMap['stars'] ?? 0,
              );
            })
            .toList();

        // Construct and return the custom User object
        return userModel.User(  // Now using your custom User model
          key: Key(uid),
          uid: data['uid'],
          name: data['name'] ?? 'No Name',
          email: data['email'] ?? 'No Email',
          photoURL: data['photoURL'] ?? '',
          myPlaces: myPlaces,
          myFavoritePlaces: myFavoritePlaces,
        );
      } else {
        print("User document does not exist.");
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }






  // Firestore collection stream
  Stream<QuerySnapshot> placesListStream = FirebaseFirestore.instance
      .collection(CloudFirestoreAPI().PLACES)
      .snapshots();

  Stream<QuerySnapshot> get placesStream => placesListStream;

  //List<ProfilePlace> buildPlaces(List<DocumentSnapshot> placesListSnapshot) => _cloudFirestoreRepository.buildPlaces(placesListSnapshot);


  List<ProfilePlace> buildMyPlaces(List<DocumentSnapshot> placesListSnapshot) {
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
          stars: data['stars'] ?? 0,
          userOwner: currentUserModel, // Pass the mapped custom UserModel
        ),
      );
    }).toList();
  }

  List<CardImageWithFabIcon> buildPlaces(List<DocumentSnapshot> placesListSnapshot) => _cloudFirestoreRepository.buildPlaces(placesListSnapshot);

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

  final _cloudFirestoreAPI = CloudFirestoreAPI(); // Add this line
  List<Place> buildPlaceObjects(List<DocumentSnapshot> placesListSnapshot) {
    return _cloudFirestoreAPI.buildPlaceObjects(placesListSnapshot);
  }

  Future<void> likePlace(String idPlace, bool isLiked) {
    return _cloudFirestoreAPI.likePlace(idPlace, isLiked);
  }

  // StreamController for the selected place
  final StreamController<Place> _placeSelectedStreamController = StreamController<Place>.broadcast();

  // Expose the stream and sink
  Stream<Place> get placeSelectedStream => _placeSelectedStreamController.stream;
  StreamSink<Place> get placeSelectedSink => _placeSelectedStreamController.sink;
  
  void signOut() async {
  await _auth_repository.signOut();
  // Do not emit anything to the stream
}

  @override
  void dispose() {
    _placeSelectedStreamController.close();
  }
}
