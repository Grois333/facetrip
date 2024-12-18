import 'package:flutter/material.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/User/model/user.dart';
import 'package:facetrip/User/ui/widgets/profile_place.dart';
import 'package:facetrip/Place/model/place.dart';

class ProfilePlacesList extends StatelessWidget {
  late UserBloc userBloc;
  late User user;
  ProfilePlacesList(this.user);

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
        stream: userBloc.myPlacesListStream(user.uid.toString()),
        builder: (context, AsyncSnapshot snapshot) {
          // Handle different connection states
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator()); // While waiting for data
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasData && snapshot.data.docs.isNotEmpty) {
                // Use `docs` instead of `documents` and pass it to `buildPlaces`
                return Column(
                  children: userBloc.buildMyPlaces(snapshot.data.docs),
                );
              } else {
                return const Center(
                  child: Text(""),
                  //child: Text("No places available."), // Show message if no places are found
                );
              }
            case ConnectionState.none:
              return const Center(
                child: Text("No connection available."), // Handle no connection
              );
            default:
              return const Center(
                child: Text("Something went wrong. Try again later."),
              );
          }
        },
      ),
    );
  }
}
