import 'package:facetrip/User/model/user.dart';
import 'package:flutter/material.dart';
import 'package:facetrip/User/ui/widgets/profile_place.dart';
import 'package:facetrip/Place/model/place.dart';


class ProfilePlacesList extends StatelessWidget {

  Place place = Place(
    key: UniqueKey(),
    id: "1",
    name: "Knuckles Mountains Range",
    description: "Hiking. Water fall hunting. Natural bath",
    urlImage: "https://images.unsplash.com/photo-1519681393784-d120267933ba?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1500&q=80",
    likes: 3,
    userOwner: User(
      key: GlobalKey(),
      uid: "1",  // Example user ID
      name: "John Doe",
      email: "john.doe@example.com",
      photoURL: "https://example.com/photo.jpg",
      myPlaces: [],
      myFavoritePlaces: [],
    ),

  );
  Place place2 = Place(
    key: UniqueKey(),
    id: "2",
    name: "Mountains",
    description: "Hiking. Water fall hunting. Natural bath', 'Scenery & Photography",
    urlImage: "https://images.unsplash.com/photo-1524654458049-e36be0721fa2?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1500&q=80",
    likes: 10,
    userOwner: User(
      key: GlobalKey(),
      uid: "2",  // Example user ID
      name: "John Doe 2",
      email: "john.doe2@example.com",
      photoURL: "https://example.com/photo.jpg",
      myPlaces: [],
      myFavoritePlaces: [],
    ),

  );
  /*Place place = new Place('Knuckles Mountains Range', 'Hiking. Water fall hunting. Natural bath', 'Scenery & Photography', '123,123,123');
  Place place2 = new Place('Mountains', 'Hiking. Water fall hunting. Natural bath', 'Scenery & Photography', '321,321,321');
  */
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          top: 10.0,
          left: 20.0,
          right: 20.0,
          bottom: 10.0
      ),
      child: Column(
        children: <Widget>[
          ProfilePlace(place),
          ProfilePlace(place2),
        ],
      ),
    );
  }

}