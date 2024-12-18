import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facetrip/Place/ui/widgets/card_image.dart';
import 'package:facetrip/User/ui/widgets/profile_place.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:facetrip/User/model/user.dart';
import 'package:facetrip/User/repository/cloud_firestore_api.dart';
import '../../Place/model/place.dart';

class CloudFirestoreRepository {

  final _cloudFirestoreAPI = CloudFirestoreAPI();

  void updateUserDataFirestore(User user) => _cloudFirestoreAPI.updateUserData(user);
  Future<void> updatePlaceData(Place place) => _cloudFirestoreAPI.updatePlaceData(place);

  List<ProfilePlace> buildMyPlaces(List<DocumentSnapshot> placesListSnapshot) => _cloudFirestoreAPI.buildMyPlaces(placesListSnapshot);
  List<CardImageWithFabIcon> buildPlaces(List<DocumentSnapshot> placesListSnapshot) => _cloudFirestoreAPI.buildPlaces(placesListSnapshot);

}