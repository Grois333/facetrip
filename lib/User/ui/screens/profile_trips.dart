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

    return Stack(
      children: <Widget>[
        ProfileBackground(),
        ListView(
          children: <Widget>[
            StreamBuilder(
              stream: userBloc.userInfoStream, // Use userInfoStream instead of authStatus
              builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );

                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.hasData && !snapshot.hasError) {
                      return Column(
                        children: [
                          ProfileHeader(user: snapshot.data!),
                          ProfilePlacesList(snapshot.data!),
                        ],
                      );
                    } else {
                      return showNotLoggedIn();
                    }
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget showNotLoggedIn() {
    return const Center(
      child: Text(
        "Usuario no logeado. Haz Login",
        style: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}