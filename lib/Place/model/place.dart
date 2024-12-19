import 'package:flutter/material.dart';
import 'package:facetrip/User/model/user.dart';

class Place {

  String id;
  String name;
  String description;
  String urlImage;
  int likes;
  bool liked;
  User userOwner; //reference to User model

  Place({
    required Key key,
    required this.id,
    required this.name,
    required this.description,
    required this.urlImage,
    required this.likes,
    this.liked = false ,
    required this.userOwner // userOwner is a reference to the User model
  });
}