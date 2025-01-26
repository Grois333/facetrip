import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facetrip/Place/model/place.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';
import 'package:flutter/material.dart';
import 'package:facetrip/widgets/floating_action_button_green.dart';

class ProfilePlaceInfo extends StatefulWidget {
  final Place place;
  final UserBloc userBloc;

  ProfilePlaceInfo({required this.place, required this.userBloc});

  @override
  _ProfilePlaceInfoState createState() => _ProfilePlaceInfoState();
}

class _ProfilePlaceInfoState extends State<ProfilePlaceInfo> {
  //late bool isLiked;
  late bool isLiked = false; // Initialize with default value

  @override
  void initState() {
    super.initState();
    // Update this to reflect the correct "liked" state based on the number of likes.
    //isLiked = widget.place.likes > 0;  // If likes are more than 0, it's considered liked
    _checkIfLiked(); // Initialize the liked state based on Firestore data
  }

  Future<void> _checkIfLiked() async {
    final currentUser = await widget.userBloc.currentUser();
    if (currentUser != null) {
      setState(() {
        isLiked = widget.place.likes.contains(currentUser.uid); // Update isLiked based on current user
      });
    }
  }

  // Toggle like state and update Firestore
  // void toggleLike() {
  //   setState(() {
  //     isLiked = !isLiked; // Toggle the like state
  //     widget.place.liked = isLiked; // Update the local place's liked state
  //     widget.userBloc.likePlace(widget.place.id, isLiked); // Update Firestore with like state
  //   });
  // }
  Future<void> _toggleLike() async {
    final currentUser = await widget.userBloc.currentUser();
    if (currentUser != null) {
      setState(() {
        // Cast to List<String> explicitly
        final likesList = widget.place.likes.cast<String>();

        if (isLiked) {
          // Remove the user's UID if it's already in the list
          likesList.remove(currentUser.uid);
        } else {
          // Add the user's UID if it's not in the list
          likesList.add(currentUser.uid);
        }

        // Update the place's likes and the isLiked state
        widget.place.likes = likesList;
        isLiked = !isLiked;
      });

      // Update Firestore with the new likes list
      widget.userBloc.likePlace(widget.place.id, widget.place.likes.cast<String>());

      // Update the user's `myFavoritePlaces` field
      final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      final placeRef = FirebaseFirestore.instance.collection('places').doc(widget.place.id);

      if (isLiked) {
        // Add the place to the user's favorite places
        await userRef.update({
          'myFavoritePlaces': FieldValue.arrayUnion([placeRef.path]),
        });
      } else {
        // Remove the place from the user's favorite places
        await userRef.update({
          'myFavoritePlaces': FieldValue.arrayRemove([placeRef.path]),
        });
      }


    }
  }



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    final place = Text(
      widget.place.name,
      style: TextStyle(
        fontFamily: 'Lato',
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    );

    final placeInfo = Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.place.description,
            style: TextStyle(
              color: Color.fromRGBO(0, 0, 0, 0.4),
              fontFamily: 'Lato',
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    // Ensure stars are between 0 and 5 and print the value for debugging
    int stars = widget.place.stars ?? 0;
    stars = stars.clamp(0, 5);  // Ensure stars are between 0 and 5

    print("Stars value: $stars");  // Debugging the stars value

    // Display the stars based on the place's stars rating
    final starIcons = Row(
      children: List.generate(5, (index) {
        if (index < stars) {
          return Icon(
            Icons.star,
            color: Colors.amber,
            size: 20.0,
          );
        } else {
          return Icon(
            Icons.star_border,
            color: Colors.amber,
            size: 20.0,
          );
        }
      }),
    );

    final card = Container(
      width: screenWidth * 0.65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black38,
            blurRadius: 10.0,
            offset: Offset(0.0, 5.0),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            place,
            placeInfo,
            starIcons,  // Add star rating here
          ],
        ),
      ),
    );

    return Stack(
      alignment: Alignment(0.8, 1.25),
      children: <Widget>[
        card,
        FloatingActionButtonGreen(
          iconData: isLiked ? Icons.favorite : Icons.favorite_border, // Toggle the icon
          onPressed: _toggleLike, // Pass the toggleLike function to onPressed
        ),
      ],
    );
  }
}
