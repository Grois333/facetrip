import 'package:flutter/material.dart';
import '/widgets/button_purple.dart';

class DescriptionPlace extends StatelessWidget {
  final String namePlace;
  final int stars; // Updated to use int for rating
  final String descriptionPlace;

  DescriptionPlace(this.namePlace, this.stars, this.descriptionPlace);

  // Function to generate the star widgets based on the rating
  List<Widget> buildStars() {
    List<Widget> starWidgets = [];

    for (int i = 0; i < 5; i++) {
      if (stars >= i + 1) {
        // Full star
        starWidgets.add(
          Container(
            margin: const EdgeInsets.only(top: 0, right: 3.0),
            child: const Icon(
              Icons.star,
              color: Color(0xFFf2C611),
            ),
          ),
        );
      } else if (stars > i && stars < i + 1) {
        // Half star
        starWidgets.add(
          Container(
            margin: const EdgeInsets.only(top: 0, right: 3.0),
            child: const Icon(
              Icons.star_half,
              color: Color(0xFFf2C611),
            ),
          ),
        );
      } else {
        // Empty star
        starWidgets.add(
          Container(
            margin: const EdgeInsets.only(top: 0, right: 3.0),
            child: const Icon(
              Icons.star_border,
              color: Color(0xFFf2C611),
            ),
          ),
        );
      }
    }
    return starWidgets;
  }

  @override
  Widget build(BuildContext context) {
    final titleStars = Container(
      margin: const EdgeInsets.only(top: 320.0, left: 20.0, right: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,  // This prevents extra spacing
        children: <Widget>[
          Text(
            namePlace,
            style: const TextStyle(
              fontFamily: "Lato",
              fontSize: 30.0,
              fontWeight: FontWeight.w900
            ),
            textAlign: TextAlign.left,
          ),
          //const SizedBox(height: 5.0),  // Add small controlled spacing
          Row(
            children: buildStars(),
          ),
        ],
      ),
    );

    final description = Container(
      margin: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: Text(
        descriptionPlace,
        style: const TextStyle(
            fontFamily: "Lato",
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF56575a)),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        titleStars, // Title and stars
        description, // Description
        Container(
          height: 55, // Set your desired height here
          child: ButtonPurple(buttonText: "User ", onPressed: () {}),
        ),
      ],
    );
  }
}
