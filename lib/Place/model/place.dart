import 'package:flutter/material.dart';
import 'package:facetrip/User/model/user.dart';

class Place {

  String id;
  String name;
  String description;
  String urlImage;
  int likes;
  User userOwner;

  Place({
    required Key key,
    required this.id,
    required this.name,
    required this.description,
    required this.urlImage,
    required this.likes,
    required this.userOwner
  });
}