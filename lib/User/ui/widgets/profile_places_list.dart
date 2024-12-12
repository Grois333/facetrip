import 'package:flutter/material.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/User/model/user.dart';
import 'package:facetrip/User/ui/widgets/profile_place.dart';
import 'package:facetrip/Place/model/place.dart';

class ProfilePlacesList extends StatelessWidget {
  late UserBloc userBloc;

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
    description: "Hiking. Water fall hunting. Natural bath, Scenery & Photography",
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

  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of<UserBloc>(context);

    return Container(
      margin: EdgeInsets.only(
        top: 10.0,
        left: 20.0,
        right: 20.0,
        bottom: 10.0,
      ),
      child: StreamBuilder(
        stream: userBloc.placesStream,
        builder: (context, AsyncSnapshot snapshot) {
          // Handle different connection states
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());  // While waiting for data
            case ConnectionState.done:
              // When the stream is done, build the places list
              if (snapshot.hasData && snapshot.data.documents.isNotEmpty) {
                return Column(
                  children: userBloc.buildPlaces(snapshot.data.documents),
                );
              } else {
                return Center(child: Text("No places available."));  // If no data found
              }
            case ConnectionState.active:
              // Handle active connection state (when data is streaming)
              if (snapshot.hasData && snapshot.data.documents.isNotEmpty) {
                return Column(
                  children: userBloc.buildPlaces(snapshot.data.documents),
                );
              } else {
                return Center(child: Text("Loading places..."));  // Show loading or placeholder
              }
            case ConnectionState.none:
            default:
              // In case there's no connection or it's an unknown state
              return Center(child: Text("Something went wrong. Try again later."));  // Error message or placeholder
          }
        },
      ),
    );
  }
}
