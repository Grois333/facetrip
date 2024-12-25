import 'package:flutter/material.dart';
import 'package:facetrip/User/model/user.dart';

class Place {
  String id;
  String name;
  String description;
  String urlImage;
  int likes;
  bool liked;
  User userOwner;
  int stars; // New field for rating

  Place({
    required Key key,
    required this.id,
    required this.name,
    required this.description,
    required this.urlImage,
    required this.likes,
    this.liked = false,
    required this.userOwner,
    this.stars = 0, // Default rating is 0
  });
}
