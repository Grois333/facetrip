import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';
import 'package:facetrip/User/model/user.dart';
import 'package:facetrip/User/ui/screens/profile_header.dart';
import 'package:facetrip/User/ui/widgets/profile_places_list.dart';
import 'package:facetrip/User/ui/widgets/profile_background.dart';

class ProfileTrips extends StatelessWidget {
  late UserBloc userBloc;

  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of<UserBloc>(context);

    return StreamBuilder(
      stream: userBloc.authStatus,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const Center(
              child: CircularProgressIndicator(),
            );

          case ConnectionState.active:
            return showProfileData(snapshot);
          case ConnectionState.done:
            if (snapshot.hasData && !snapshot.hasError) {
              return showProfileData(snapshot);
            } else {
              return showNotLoggedIn();
            }

          default:
            return const Center(
              child: Text("Something went wrong."),
            );
        }
      },
    );
  }

  Widget showProfileData(AsyncSnapshot snapshot) {
    // Create a `User` object with required parameters
    var user = User(
      key: UniqueKey(),
      uid: snapshot.data.uid ?? "No UID",
      name: snapshot.data.displayName ?? "No Name",
      email: snapshot.data.email ?? "No Email",
      photoURL: snapshot.data.photoURL ?? "No Photo",
      myPlaces: [],
      myFavoritePlaces: [],
    );

    return Stack(
      children: <Widget>[
        ProfileBackground(),
        ListView(
          children: <Widget>[
            ProfileHeader(user), // Removed user parameter
            ProfilePlacesList(user), // Adjust as needed
          ],
        ),
      ],
    );
  }

  Widget showNotLoggedIn() {
    return Stack(
      children: <Widget>[
        ProfileBackground(),
        ListView(
          children: <Widget>[
            const Center(
              child: Text(
                "Usuario no logeado. Haz Login",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
