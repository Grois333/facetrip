import 'dart:io';
import 'package:facetrip/Place/model/place.dart';
import 'package:facetrip/Place/ui/widgets/card_image.dart';
import 'package:facetrip/widgets/button_purple.dart';
import 'package:facetrip/widgets/text_input.dart';
import 'package:facetrip/widgets/title_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:facetrip/widgets/gradient_back.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/User/model/user.dart' as user_model;
import 'package:facetrip/User/bloc/bloc_user.dart' as user_bloc;
import 'package:image_picker/image_picker.dart';

class AddPlaceScreen extends StatefulWidget {
  final File? imageFile;

  AddPlaceScreen({this.imageFile});

  @override
  State createState() {
    return _AddPlaceScreen();
  }
}

class _AddPlaceScreen extends State<AddPlaceScreen> {
  late TextEditingController _controllerTitlePlace;
  late TextEditingController _controllerDescriptionPlace;
  late File? _imageFile;
  bool _isSubmitting = false; // Track submission status
  int _selectedStars = 0; // Variable to track star rating

  @override
  void initState() {
    super.initState();
    _controllerTitlePlace = TextEditingController();
    _controllerDescriptionPlace = TextEditingController();
    _imageFile = widget.imageFile;
  }

  @override
  void dispose() {
    _controllerTitlePlace.dispose();
    _controllerDescriptionPlace.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        print("Captured image path: ${_imageFile!.path}");
      });
    } else {
      print("No image captured.");
    }
  }

  Future<void> _handleAddPlace(user_bloc.UserBloc userBloc, user_model.User currentUserModel) async {
    if (_imageFile != null) {
      String path = "${currentUserModel.uid}/${DateTime.now().toString()}.jpg";

      try {
        setState(() {
          _isSubmitting = true; // Start loading
        });

        final storageRef = FirebaseStorage.instance.ref().child(path);
        final uploadTask = storageRef.putFile(_imageFile!);
        final snapshot = await uploadTask;

        final imageUrl = await snapshot.ref.getDownloadURL();

        await userBloc.updatePlaceData(Place(
          key: UniqueKey(),
          id: "1",
          name: _controllerTitlePlace.text,
          description: _controllerDescriptionPlace.text,
          likes: [],
          urlImage: imageUrl,
          userOwner: currentUserModel,
          stars: _selectedStars, // Save the selected stars
        ));

        Navigator.pop(context);
      } catch (error) {
        print("Failed to upload image or save data: $error");
      } finally {
        setState(() {
          _isSubmitting = false; // Stop loading
        });
      }
    } else {
      print("No image selected.");
    }
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedStars = index + 1; // Update the star rating
            });
          },
          child: Icon(
            Icons.star,
            color: index < _selectedStars ? Colors.amber : Colors.grey,
            size: 40.0,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 120.0, bottom: 20.0),
            child: ListView(
              children: <Widget>[
                
                Container(
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: _imageFile != null && _imageFile!.path.isNotEmpty
                            ? Image.file(
                                _imageFile!,  // Use the File object directly
                                width: 350.0,
                                height: 250.0,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 350.0,
                                height: 250.0,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,  // Transparent background for the empty card
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black38,  // Custom shadow color
                                      blurRadius: 15.0,  // Soft blur effect
                                      offset: Offset(0.0, 7.0),  // Shadow direction and spread
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      Positioned(
                        top: 10.0,
                        right: 10.0,
                        child: IconButton(
                          icon: Icon(
                            Icons.camera_alt,
                            size: 40.0,
                            color: Colors.white,
                          ),
                          onPressed: _openCamera,
                        ),
                      ),
                    ],
                  ),
                ),




                Container(
                  margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: TextInput(
                    hintText: "Title",
                    inputType: TextInputType.text,
                    maxLines: 1,
                    controller: _controllerTitlePlace,
                  ),
                ),
                TextInput(
                  hintText: "Description",
                  inputType: TextInputType.multiline,
                  maxLines: 4,
                  controller: _controllerDescriptionPlace,
                ),
                Container(
                  margin: EdgeInsets.only(top: 20.0),
                  child: _buildStarRating(), // Add the star rating widget here
                ),
                Container(
                  width: 70.0,
                  child: ButtonPurple(
                    buttonText: "Add Place",
                    onPressed: () async {
                      if (currentUser != null) {
                        user_model.User currentUserModel = user_model.User(
                          key: UniqueKey(),
                          uid: currentUser.uid,
                          email: currentUser.email ?? "",
                          name: currentUser.displayName ?? "Anonymous",
                          photoURL: currentUser.photoURL ?? "",
                          myPlaces: [],
                          myFavoritePlaces: [],
                        );
                        await _handleAddPlace(userBloc, currentUserModel);
                      } else {
                        print("No user is logged in.");
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_isSubmitting)
            ModalBarrier(
              dismissible: false,
              color: Colors.black.withOpacity(0.5),
            ),
          if (_isSubmitting)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
