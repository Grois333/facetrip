import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facetrip/User/repository/cloud_firestore_api.dart';
import 'package:facetrip/User/ui/widgets/email_auth_component.dart';
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

  // At the top of your widget
  bool _isSigningIn = false;

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
      resizeToAvoidBottomInset: true,
      body: Stack(
        alignment: Alignment.center,

        children: <Widget>[
          GradientBack("", 810),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  Container(
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
                //),

                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                    ),

                  // Add our new email authentication component here
                  EmailAuthComponent(),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        "OR",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  

                  ButtonGreen(
                    text: "Login with Gmail",
                    onPressed: () async {
                      // Don't await signOut if it doesn't return a Future
                      userBloc.signOut(); // Clear existing session

                      if (_isSigningIn) return; // Prevent multiple sign-in attempts

                      setState(() {
                        _isSigningIn = true;
                      });
                      
                      try {
                        firebase_auth.User? firebaseUser = await userBloc.signIn();
                        
                        if (firebaseUser != null) {
                          print("Signed in as: ${firebaseUser.uid}");
                          
                          // Directly check if user document exists
                          bool userExists = false;
                          try {
                            DocumentSnapshot userDoc = await FirebaseFirestore.instance
                                .collection(CloudFirestoreAPI().USERS)
                                .doc(firebaseUser.uid)
                                .get();
                            userExists = userDoc.exists;
                            print("User document exists check: $userExists");
                          } catch (e) {
                            print("Error checking user existence: $e");
                          }
                          
                          if (userExists) {
                            // User exists - load their data
                            try {
                              User? existingUser = await userBloc.getUserData(firebaseUser.uid);
                              
                              if (existingUser != null) {
                                print("Existing user found: ${existingUser.uid}");
                                print("User myPlaces: ${existingUser.myPlaces.length}");
                                print("User myFavoritePlaces: ${existingUser.myFavoritePlaces.length}");
                                
                                // Update any necessary session data without overwriting user data
                                // For example, you might want to update the last login time
                                // userBloc.updateLastLoginTime(firebaseUser.uid);
                                
                                // Additional logic for existing user
                              } else {
                                print("User document exists but couldn't be loaded properly.");
                                // Handle this edge case - maybe update minimal user data
                              }
                            } catch (e) {
                              print("Error loading existing user: $e");
                            }
                          } else {
                            // User doesn't exist - create new user
                            print("No existing user found. Creating new user.");
                            
                            User newUser = User(
                              key: Key(firebaseUser.uid),
                              uid: firebaseUser.uid,
                              name: firebaseUser.displayName ?? "",
                              email: firebaseUser.email ?? "",
                              photoURL: firebaseUser.photoURL ?? "",
                              myPlaces: [], // Initialize as empty list
                              myFavoritePlaces: [], // Initialize as empty list
                            );
                            
                            userBloc.updateUserData(newUser);
                            print("New user registered.");
                          }
                        }
                      } catch (e) {
                        print("Sign-in failed: $e");
                      } finally {
                        setState(() {
                          _isSigningIn = false;
                        });
                      }
                    },
                    width: 300.0,
                    height: 50.0,
                  ),




                ],
              
              ),
            ),
          ),
        ],
      ),
    );
  }

  
}
