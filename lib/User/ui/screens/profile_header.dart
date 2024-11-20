import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Alias firebase_auth.User
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';
import 'package:facetrip/User/model/user.dart';
import 'package:facetrip/User/ui/widgets/user_info.dart';
import 'package:facetrip/User/ui/widgets/button_bar.dart';

class ProfileHeader extends StatelessWidget {
  late UserBloc userBloc;
  late User user;

  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of<UserBloc>(context);

    return StreamBuilder(
      stream: userBloc.streamFirebase,
      builder: (BuildContext context, AsyncSnapshot snapshot){
        switch(snapshot.connectionState){
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          case ConnectionState.none:
            return CircularProgressIndicator();
          case ConnectionState.active:
            return showProfileData(snapshot);
          case ConnectionState.done:
            return showProfileData(snapshot);
        }

      },
    );


    /*final title = Text(
      'Profile',
      style: TextStyle(
          fontFamily: 'Lato',
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 30.0
      ),
    );

    return Container(
      margin: EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 50.0
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              title
            ],
          ),
          UserInfo('assets/img/ann.jpg', 'Isaac Groisman','mail@test.com'),
          ButtonsBar()
        ],
      ),
    );*/
  }


  Widget showProfileData(AsyncSnapshot snapshot) {
    if(!snapshot.hasData ||snapshot.hasError){
      print("No logeado");
      return Container(
        margin: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 50.0
        ),
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(),
            Text("No se pudo cargar la información. Haz login")
          ],
        ),
      );
    }else{
      print("Logeado");
      print(snapshot.data);

       // Map Firebase User data to your custom User model
    final firebaseUser = snapshot.data as firebase_auth.User;
    user = User(
      key: Key(firebaseUser.uid), // Pass unique Key
      uid: firebaseUser.uid, // Pass uid
      name: firebaseUser.displayName ?? "No Name", // Handle null displayName
      email: firebaseUser.email ?? "No Email", // Handle null email
      photoURL: firebaseUser.photoURL ?? "", // Handle null photoURL
      myPlaces: [], // Default to empty list
      myFavoritePlaces: [], // Default to empty list
    );
      
      
      final title = Text(
        'Profile',
        style: TextStyle(
            fontFamily: 'Lato',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30.0
        ),
      );

      return Container(
        margin: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 50.0
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                title
              ],
            ),
            UserInfo(user),
            ButtonsBar()
          ],
        ),
      );

    }
  }

}