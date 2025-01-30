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


  void updateUserData(User user) async {
  // Get the current authenticated user's UID
  auth.User? currentUser = _auth.currentUser;

  if (currentUser == null) {
    print("User is not authenticated.");
    return; // Abort if the user is not authenticated
  }

  // Check if the current user's UID matches the UID of the user data being updated
  if (currentUser.uid != user.uid) {
    print("User UID does not match. Aborting update.");
    return; // Abort if the UIDs don't match
  }

  // Proceed with updating the user data if the UIDs match
  DocumentReference ref = _db.collection(USERS).doc(user.uid);
  try {
    await ref.set({
      'uid': user.uid,
      'name': user.name,
      'email': user.email,
      'photoURL': user.photoURL,
      'myPlaces': user.myPlaces,
      'myFavoritePlaces': user.myFavoritePlaces,
      'registeredDate': DateTime.now(),
    }, SetOptions(merge: true));
      print("User data updated successfully.");
    } catch (e) {
      print("Error updating user data: $e");
    }
  }


  Future<void> updatePlaceData(Place place) async {
    CollectionReference refPlaces = _db.collection(PLACES);

    try {
      auth.User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }

      // Add the new place
      DocumentReference placeRef = await refPlaces.add({
        'name': place.name,
        'description': place.description,
        'likes': place.likes,
        'urlImage': place.urlImage,
        'stars': place.stars, // Include stars
        'userOwner': _db.doc("$USERS/${user.uid}"),
      });

      // Safely update the user's `myPlaces`
      DocumentReference userRef = _db.collection(USERS).doc(user.uid);
      await userRef.update({
        'myPlaces': FieldValue.arrayUnion([placeRef.path]) // Save path as a string
      });

      print("Place added successfully: ${placeRef.id}");
    } catch (e) {
      print("Error in updatePlaceData: $e");
    }
  }



  // Build a list of ProfilePlace widgets from Firestore snapshots
  List<ProfilePlace> buildMyPlaces(
    List<DocumentSnapshot> placesListSnapshot, Function(String) onDelete) {
    List<ProfilePlace> profilePlaces = [];

    placesListSnapshot.forEach((p) {
      Map<String, dynamic>? data = p.data() as Map<String, dynamic>?;

      if (data != null) {
        profilePlaces.add(
          ProfilePlace(
            place: Place(
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
            onDelete: onDelete, // Pass the onDelete callback
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

        // placesCard.add(CardImageWithFabIcon(
        //   pathImage: data["urlImage"] ?? "",
        //   width: width,
        //   height: height,
        //   left: left,
        //   onPressedFabIcon: () {
        //     // Toggle the liked state and update Firestore
        //     likePlace(p.id, !isLiked); 
        //   },
        //   iconData: isLiked ? Icons.favorite : Icons.favorite_border, // Display heart icon based on state
        // ));

        placesCard.add(CardImageWithFabIcon(
          pathImage: data["urlImage"] ?? "",
          width: width,
          height: height,
          left: left,

          onPressedFabIcon: () async {
            // Get the current user's ID
            auth.User? currentUser = auth.FirebaseAuth.instance.currentUser;

            if (currentUser != null) {
              // Pass the user's ID to toggle like
              await likePlace(p.id, currentUser.uid);
            } else {
              print("User not authenticated.");
            }
          },

          
          iconData: isLiked ? Icons.favorite : Icons.favorite_border,
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
        likes: [],
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




  // Future<void> likePlace(String idPlace, bool isLiked) async {
  //   try {
  //     // Update the 'likes' field based on the toggled value
  //     await _db.collection(PLACES).doc(idPlace).update({
  //       'likes': isLiked ? 1 : 0, // 1 if liked, 0 if not liked
  //     });
  //   } catch (e) {
  //     print("Error toggling like for place: $e");
  //   }
  // }

  Future<void> likePlace(String idPlace, String userId) async {
    try {
      DocumentReference placeRef = _db.collection(PLACES).doc(idPlace);
      DocumentSnapshot placeSnapshot = await placeRef.get();

      if (placeSnapshot.exists) {
        List<dynamic> likes = placeSnapshot['likes'] ?? [];

        if (likes.contains(userId)) {
          await placeRef.update({'likes': FieldValue.arrayRemove([userId])});
        } else {
          await placeRef.update({'likes': FieldValue.arrayUnion([userId])});
        }
      } else {
        print("Place with ID $idPlace does not exist.");
      }
    } catch (e) {
      print("Error toggling like for place: $e");
    }
  }






}