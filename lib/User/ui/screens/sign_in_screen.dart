import 'package:facetrip/face_trips_cupertino.dart';
import 'package:flutter/material.dart';
import 'package:facetrip/widgets/gradient_back.dart';
import 'package:facetrip/widgets/button_green.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Alias the Firebase User
import 'package:facetrip/User/model/user.dart'; // Local User model

class SignInScreen extends StatefulWidget {
  @override
  State createState() {
    return _SignInScreen();
  }
}

class _SignInScreen extends State<SignInScreen> {
  late UserBloc userBloc;
  late double screenWidth;

  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of(context);
    screenWidth = MediaQuery.of(context).size.width;
    return _handleCurrentSession();
  }

  Widget _handleCurrentSession() {
    return StreamBuilder(
      stream: userBloc.authStatus,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
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
                  width: screenWidth,
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    "Welcome \n This is your Travel App",
                    style: TextStyle(
                      fontSize: 37.0,
                      fontFamily: "Lato",
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              ButtonGreen(
                text: "Login with Gmail",

                onPressed: () async {
                  userBloc.signOut(); // Clear existing session
                  try {
                    firebase_auth.User? firebaseUser = await userBloc.signIn();

                    if (firebaseUser != null) {
                      print("Signed in as: ${firebaseUser.uid}");

                      // Attempt to fetch the user from Firestore
                      User? existingUser = await userBloc.getUserData(firebaseUser.uid);

                      if (existingUser == null) {
                        print("No existing user found in Firestore for UID: ${firebaseUser.uid}. Creating new user.");
                        
                        // User doesn't exist, so create a new record
                        userBloc.updateUserData(
                          User(
                            key: Key(firebaseUser.uid),
                            uid: firebaseUser.uid,
                            name: firebaseUser.displayName ?? "",
                            email: firebaseUser.email ?? "",
                            photoURL: firebaseUser.photoURL ?? "",
                            myPlaces: [], // Initialize as empty list
                            myFavoritePlaces: [], // Initialize as empty list
                          ),
                        );

                        print("New user registered.");
                      } else {
                        print("Existing user found: UID: ${existingUser.uid}, Name: ${existingUser.name}");
                        print("User myPlaces: ${existingUser.myPlaces}");
                        print("User myFavoritePlaces: ${existingUser.myFavoritePlaces}");
                        
                        // User exists; no need to update
                        print("User already exists. No update needed.");
                      }
                    }
                  } catch (e) {
                    print("Sign-in failed: $e");
                  }
                },



                width: 300.0,
                height: 50.0,
              ),



            ],
          ),
        ],
      ),
    );
  }

  
}
