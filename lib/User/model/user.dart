import 'package:flutter/material.dart';
import 'package:facetrip/Place/model/place.dart';

class User {
  final String uid;
  final String name;
  final String email;
  final String photoURL;
  final List<Place> myPlaces;
  final List<Place> myFavoritePlaces;
  String description; // Added description field

  //myFavoritePlaces
  //myPlaces

  User({
    required Key key,
    required this.uid,
    required this.name,
    required this.email,
    required this.photoURL,
    this.myPlaces = const [],
    this.myFavoritePlaces = const [],
    this.description = "There is an amazing place in Sri Lanka", // Default value
  });

}