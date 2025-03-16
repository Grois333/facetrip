import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';
import 'package:facetrip/User/model/user.dart';
import '/widgets/gradient_back.dart';
import '/Place/ui/widgets/card_image_list.dart';

class HeaderAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserBloc userBloc = BlocProvider.of<UserBloc>(context);

    return StreamBuilder(
      stream: userBloc.authStatus,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          case ConnectionState.none:
            return Center(child: CircularProgressIndicator());
          case ConnectionState.active:
          case ConnectionState.done:
            return showPlacesData(snapshot);
          default:
            return showPlacesData(snapshot);
        }
      },
    );
  }

  Widget showPlacesData(AsyncSnapshot snapshot) {
    if (!snapshot.hasData || snapshot.hasError) {
      return Stack(
        children: [
          GradientBack("Welcome", 250.0),
          Center(child: Text("User not logged in. Make Login")),
        ],
      );
    } else {

      // Get the firebase_auth.User from snapshot
      final firebaseUser = snapshot.data;
      
      // Create a User object with proper null safety
      User user = User(
        key: UniqueKey(),
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? "", // Use empty string as fallback
        email: firebaseUser.email ?? "",      // Use empty string as fallback
        photoURL: firebaseUser.photoURL ?? "", // Use empty string as fallback
        myPlaces: [],
        myFavoritePlaces: [],
      );

      return Stack(
        children: [
          GradientBack("Welcome", 250.0),
          // Pass the User object to CardImageList
          CardImageList(user), // Pass the User object here directly
        ],
      );
    }
  }
}
