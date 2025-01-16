import 'package:facetrip/Place/model/place.dart';
import 'package:facetrip/User/model/user.dart';
import 'package:flutter/material.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'review.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import for Firebase

class ReviewList extends StatelessWidget {
  final String userPhotoUrl;
  final String userName;
  final Place? selectedPlace;

  ReviewList({
    required this.userPhotoUrl,
    required this.userName,
    required this.selectedPlace,
  });

  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = BlocProvider.of<UserBloc>(context);

    return StreamBuilder(
      stream: userBloc.placesStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasData) {
          // Fetch current user UID and access their places
          return FutureBuilder(
            future: _getUserPlacesCount(_extractUserId(selectedPlace?.userOwner)), // Get the places count asynchronously
            builder: (context, AsyncSnapshot<int> userPlacesSnapshot) {
              if (userPlacesSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (userPlacesSnapshot.hasData) {
                final numberOfPlaces = userPlacesSnapshot.data ?? 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Review(
                      userPhotoUrl.isNotEmpty ? userPhotoUrl : 'https://www.example.com/default_image.png',
                      userName,
                      "$numberOfPlaces place${numberOfPlaces > 1 ? 's' : ''}",
                      "There is an amazing place in Sri Lanka", // Placeholder text
                    ),
                  ],
                );
              } else {
                return Text("User places not found.");
              }
            },
          );
        } else {
          return Text("No places found.");
        }
      },
    );
  }

  // Helper to extract the user ID from userOwner
  String? _extractUserId(dynamic userOwner) {
    if (userOwner is String) {
      return userOwner;
    } else if (userOwner is User) {
      return userOwner.uid;
    }
    return null;
  }

  // Fetch the number of places from the Firestore user's document
  Future<int> _getUserPlacesCount(String? userId) async {
    if (userId == null) return 0;

    try {
      final userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final myPlaces = userSnapshot.data()?['myPlaces'] as List<dynamic>? ?? [];
      return myPlaces.length;
    } catch (e) {
      print("Error fetching user places: $e");
      return 0;
    }
  }
  
}
