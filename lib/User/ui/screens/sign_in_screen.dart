import 'package:facetrip/face_trips_cupertino.dart';
import 'package:flutter/material.dart';
import 'package:facetrip/widgets/gradient_back.dart';
import 'package:facetrip/widgets/button_green.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:facetrip/User/model/user.dart';



class SignInScreen extends StatefulWidget {

  @override
  State createState() {
    return _SignInScreen();
  }
}


class _SignInScreen extends State<SignInScreen> {

  late  UserBloc userBloc;
  late double screenWidht;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    userBloc = BlocProvider.of(context);
    screenWidht = MediaQuery.of(context).size.width;
    //return signInGoogleUI();
    return _handleCurrentSession();
  }

   Widget _handleCurrentSession(){
    return StreamBuilder(
      stream: userBloc.authStatus,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        //snapshot- data - Object User
        if(!snapshot.hasData || snapshot.hasError) {
          return signInGoogleUI();
        } else {
          return FaceTripsCupertino();
        }
      },
    );

  }

  Widget signInGoogleUI() {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          GradientBack("", 810),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Container(
                  width: screenWidht,
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text("Welcome \n This is your Travel App",
                    style: TextStyle(
                        fontSize: 37.0,
                        fontFamily: "Lato",
                        color: Colors.white,
                        fontWeight: FontWeight.bold


                    ),
                  ),
                ),
              ),
              ButtonGreen(text: "Login with Gmail",
                // onPressed: () {
                //   userBloc.signIn().then((User user) => print("El usuario es ${user.displayName}"));
                // },
                onPressed: () async {
                  userBloc.signOut();
                  try {
                    //User user = await userBloc.signIn();
                    //print("El usuario es ${user.displayName}");

                    userBloc.signIn().then((auth.User firebaseUser) {
                      // Use Firebase's User object and map it to your custom User
                      userBloc.updateUserData(
                        User(
                          key: Key('user_${firebaseUser.uid}'), // Generate a unique Key using the UID
                          uid: firebaseUser.uid,
                          name: firebaseUser.displayName ?? "", // Handle null values
                          email: firebaseUser.email ?? "", // Handle null values
                          photoURL: firebaseUser.photoURL ?? "", // Handle null values
                          myPlaces: [], // Placeholder, update as needed
                          myFavoritePlaces: [], // Placeholder, update as needed
                        ),
                      );
                    });

                  } catch (e) {
                    print("Sign-in failed: $e");
                    // Display error to the user
                  }
                },
                width: 300.0,
                height: 50.0,
              )

            ],
          )
        ],
      ),
    );
  }


}