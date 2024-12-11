import 'dart:io';
import 'package:facetrip/Place/model/place.dart';
import 'package:facetrip/Place/ui/widgets/card_image.dart';
import 'package:facetrip/Place/ui/widgets/title_input_location.dart';
import 'package:facetrip/widgets/button_purple.dart';
import 'package:facetrip/widgets/text_input.dart';
import 'package:facetrip/widgets/title_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:facetrip/widgets/gradient_back.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/User/model/user.dart' as user_model;
import 'package:facetrip/User/bloc/bloc_user.dart' as user_bloc;
import 'package:image_picker/image_picker.dart';  // Import ImagePicker for camera functionality
import 'dart:async';

class AddPlaceScreen extends StatefulWidget {
  final File? imageFile;

  // Constructor to accept the image file
  AddPlaceScreen({this.imageFile});

  @override
  State createState() {
    return _AddPlaceScreen();
  }
}

class _AddPlaceScreen extends State<AddPlaceScreen> {
  // Declare controllers as instance variables so they persist across rebuilds
  late TextEditingController _controllerTitlePlace;
  late TextEditingController _controllerDescriptionPlace;
  late File? _imageFile;  // Use nullable File

  @override
  void initState() {
    super.initState();
    // Initialize the controllers
    _controllerTitlePlace = TextEditingController();
    _controllerDescriptionPlace = TextEditingController();
    _imageFile = widget.imageFile;  // Set the initial image file from widget constructor
  }

  @override
  void dispose() {
    // Dispose of the controllers to avoid memory leaks
    _controllerTitlePlace.dispose();
    _controllerDescriptionPlace.dispose();
    super.dispose();
  }

  // Function to open the camera and capture an image
  Future<void> _openCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);  // Store the captured image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the UserBloc instance using the alias
    user_bloc.UserBloc userBloc = BlocProvider.of<user_bloc.UserBloc>(context);

    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          GradientBack('', 300.0),
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 25.0, left: 5.0),
                child: SizedBox(
                  height: 45.0,
                  width: 45.0,
                  child: IconButton(
                    icon: Icon(Icons.keyboard_arrow_left, color: Colors.white, size: 45),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.only(top: 45.0, left: 20.0, right: 10.0),
                  child: TitleHeader(title: "Add a new Place"),
                ),
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 120.0, bottom: 20.0),
            child: ListView(
              children: <Widget>[

                // Image card
                Container(
                  alignment: Alignment.center,
                  child: Stack(
                    children: [

                      CardImageWithFabIcon(
                        pathImage: _imageFile?.path ?? "", // Image from the passed file
                        iconData: Icons.favorite_border, // You can keep this for the image card
                        width: 350.0,
                        height: 250.0,
                        onPressedFabIcon: () {
                          // Keep this for image card functionality if needed
                        },
                        left: 0,
                      ),

                      Positioned(
                        top: 10.0,
                        right: 10.0,
                        child: IconButton(
                          icon: Icon(
                            Icons.camera_alt,
                            size: 40.0,
                            color: Colors.white, // Set the icon color
                          ),
                          onPressed: _openCamera, // Trigger the same function
                        ),
                      ),
                    ],
                  ),
                ),

                // Title TextField
                Container(
                  margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: TextInput(
                    hintText: "Title",
                    inputType: TextInputType.text,
                    maxLines: 1,
                    controller: _controllerTitlePlace,
                  ),
                ),
                // Description TextField
                TextInput(
                  hintText: "Description",
                  inputType: TextInputType.multiline,
                  maxLines: 4,
                  controller: _controllerDescriptionPlace,
                ),
                // Location TextField
                Container(
                  margin: EdgeInsets.only(top: 20.0),
                  child: TextInputLocation(
                    hintText: "Add Location",
                    iconData: Icons.location_on,
                  ),
                ),
                // Add Place Button
                Container(
                  width: 70.0,
                  child: ButtonPurple(
                    buttonText: "Add Place",
                    onPressed: () {
                      if (currentUser != null) {
                        // Correctly create a User instance using the alias
                        user_model.User currentUserModel = user_model.User(
                          key: UniqueKey(),
                          uid: currentUser.uid,
                          email: currentUser.email ?? "",
                          name: currentUser.displayName ?? "Anonymous",
                          photoURL: currentUser.photoURL ?? "",
                          myPlaces: [], // Empty list for myPlaces
                          myFavoritePlaces: [], // Empty list for myFavoritePlaces
                        );

                        // Dynamically associate the place with the current user
                        userBloc.updatePlaceData(Place(
                          key: UniqueKey(),
                          id: "1",
                          name: _controllerTitlePlace.text,
                          description: _controllerDescriptionPlace.text,
                          likes: 0,
                          urlImage: _imageFile?.path ?? "https://example.com/default-image.jpg", // Use dynamic URL if needed
                          userOwner: currentUserModel, // Pass the User model here
                        )).then((_) {
                          print("Place successfully added to Firestore!");
                          Navigator.pop(context);
                        }).catchError((error) {
                          print("Failed to add place: $error");
                        });
                      } else {
                        print("No user is logged in.");
                      }
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
