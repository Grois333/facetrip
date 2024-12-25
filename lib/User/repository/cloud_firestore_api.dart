import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facetrip/Place/ui/widgets/card_image.dart';
import 'package:facetrip/User/model/user.dart';
import 'package:facetrip/User/ui/widgets/profile_place.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import '../../Place/model/place.dart';

class CloudFirestoreAPI{
  final String USERS = "users";
  final String PLACES = "places";

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;


  void updateUserData(User user) async{
    DocumentReference ref = _db.collection(USERS).doc(user.uid);
    return await ref.set({
      'uid': user.uid,
      'name': user.name,
      'email': user.email,
      'photoURL': user.photoURL,
      'myPlaces': user.myPlaces,
      'muFavoritePlaces': user.myFavoritePlaces,
      'lastSignIn': DateTime.now()
    }, SetOptions(merge: true));
  }

  Future<void> updatePlaceData(Place place) async {
    CollectionReference refPlaces = _db.collection(PLACES);

    auth.User? user = _auth.currentUser;
    if (user == null) {
      return print("user is null");
    } else {
      refPlaces.add({
        'name': place.name,
        'description': place.description,
        'likes': place.likes,
        'urlImage': place.urlImage,
        'stars': place.stars, // Include the stars rating
        'userOwner': _db.doc("$USERS/${user.uid}"),
      }).then((dr) {
        dr.get().then((snapshot) {
          snapshot.id; // ID Places
          DocumentReference refUsers = _db.collection(USERS).doc(user.uid);
          refUsers.update({
            'myPlaces': FieldValue.arrayUnion([_db.doc("$PLACES/${snapshot.id}")])
          });
        });
      });
    }
  }

  // Build a list of ProfilePlace widgets from Firestore snapshots
  List<ProfilePlace> buildMyPlaces(List<DocumentSnapshot> placesListSnapshot) {
    List<ProfilePlace> profilePlaces = [];
    placesListSnapshot.forEach((p) {
      Map<String, dynamic>? data = p.data() as Map<String, dynamic>?;
      if (data != null) {
        profilePlaces.add(
          ProfilePlace(
            Place(
              key: UniqueKey(),
              id: p.id, // Use Firestore document ID as the ID
              name: data['name'] ?? 'Unnamed Place',
              description: data['description'] ?? 'No description available',
              urlImage: data['urlImage'] ?? '', // Provide default URL if missing
              likes: data['likes'] ?? 0,
              userOwner: User(
                key: UniqueKey(),
                uid: data['userOwner'] != null
                    ? (data['userOwner'] as DocumentReference).id
                    : 'Unknown Owner',
                name: 'Unknown', // Default values if owner data is incomplete
                email: '',
                photoURL: '',
                myPlaces: [],
                myFavoritePlaces: [],
              ),
            ),
          ),
        );
      }
    });

    return profilePlaces;
  }

  List<CardImageWithFabIcon> buildPlaces(List<DocumentSnapshot> placesListSnapshot) {
    List<CardImageWithFabIcon> placesCard = [];
    double width = 300.0;
    double height = 350.0;
    double left = 20.0;

    for (var p in placesListSnapshot) {
      Map<String, dynamic>? data = p.data() as Map<String, dynamic>?;

      if (data != null) {
        bool isLiked = (data['likes'] ?? 0) == 1; // Determine if the place is liked (1 = liked, 0 = not liked)

        placesCard.add(CardImageWithFabIcon(
          pathImage: data["urlImage"] ?? "",
          width: width,
          height: height,
          left: left,
          onPressedFabIcon: () {
            // Toggle the liked state and update Firestore
            likePlace(p.id, !isLiked); 
          },
          iconData: isLiked ? Icons.favorite : Icons.favorite_border, // Display heart icon based on state
        ));
      }
    }

    return placesCard;
  }

  List<Place> buildPlaceObjects(List<DocumentSnapshot> placesListSnapshot) {
  return placesListSnapshot.map((p) {
    Map<String, dynamic>? data = p.data() as Map<String, dynamic>?;

    if (data != null) {
      return Place(
        key: UniqueKey(),
        id: p.id, // Use Firestore document ID as the ID
        name: data['name'] ?? 'Unnamed Place',
        description: data['description'] ?? 'No description available',
        urlImage: data['urlImage'] ?? '', // Provide default URL if missing
        likes: data['likes'] ?? 0,
        liked: (data['likes'] ?? 0) == 1, // Determine liked state
        stars: data['stars'] is int ? data['stars'] : int.tryParse(data['stars'].toString()) ?? 0,
        userOwner: User(
                key: UniqueKey(),
                uid: data['userOwner'] != null
                    ? (data['userOwner'] as DocumentReference).id
                    : 'Unknown Owner',
                name: 'Unknown', // Default values if owner data is incomplete
                email: '',
                photoURL: '',
                myPlaces: [],
                myFavoritePlaces: [],
        )
      );
    } else {
      return Place(
        key: UniqueKey(),
        id: '',
        name: 'Unknown',
        description: 'No data available',
        urlImage: '',
        likes: 0,
        liked: false,
        userOwner: User(
                key: UniqueKey(),
                uid: data?['userOwner'] != null
                    ? (data?['userOwner'] as DocumentReference).id
                    : 'Unknown Owner',
                name: 'Unknown', // Default values if owner data is incomplete
                email: '',
                photoURL: '',
                myPlaces: [],
                myFavoritePlaces: [],
        )
      );
    }
  }).toList();
}




  Future<void> likePlace(String idPlace, bool isLiked) async {
    try {
      // Update the 'likes' field based on the toggled value
      await _db.collection(PLACES).doc(idPlace).update({
        'likes': isLiked ? 1 : 0, // 1 if liked, 0 if not liked
      });
    } catch (e) {
      print("Error toggling like for place: $e");
    }
  }




}