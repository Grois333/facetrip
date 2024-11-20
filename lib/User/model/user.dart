import 'package:flutter/material.dart';
import 'package:facetrip/Place/model/place.dart';

class User {
  final String uid;
  final String name;
  final String email;
  final String photoURL;
  final List<Place> myPlaces;
  final List<Place> myFavoritePlaces;

  //myFavoritePlaces
  //myPlaces

  User({
    required Key key,
    required this.uid,
    required this.name,
    required this.email,
    required this.photoURL,
    required this.myPlaces,
    required this.myFavoritePlaces
  });

}