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
  late bool isLiked;

  @override
  void initState() {
    super.initState();
    // Update this to reflect the correct "liked" state based on the number of likes.
    isLiked = widget.place.likes > 0;  // If likes are more than 0, it's considered liked
  }

  // Toggle like state and update Firestore
  void toggleLike() {
    setState(() {
      isLiked = !isLiked; // Toggle the like state
      widget.place.liked = isLiked; // Update the local place's liked state
      widget.userBloc.likePlace(widget.place.id, isLiked); // Update Firestore with like state
    });
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
          onPressed: toggleLike, // Pass the toggleLike function to onPressed
        ),
      ],
    );
  }
}
