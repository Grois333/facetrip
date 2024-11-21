import 'package:flutter/material.dart';
import 'card_image.dart';

class CardImageList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double width = 300.0;
    double height = 250.0;
    double left = 20.0;

    return Container(
      height: 350.0,
      child: ListView(
        padding: EdgeInsets.all(50.0),
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          CardImageWithFabIcon(pathImage: "assets/img/beach_palm.jpeg", iconData: Icons.favorite_border,
            width: width,
            height: height,
            onPressedFabIcon: () => {},
            left: left,
            ),
          CardImageWithFabIcon(pathImage:"assets/img/mountain.jpeg", iconData: Icons.favorite_border,
            width: width,
            height: height,
            onPressedFabIcon: () => {},
            left: left,),
          CardImageWithFabIcon(pathImage:"assets/img/mountain_stars.jpeg", iconData: Icons.favorite_border,
            width: width,
            height: height,
            onPressedFabIcon: () => {},
            left: left,),
          CardImageWithFabIcon(pathImage:"assets/img/river.jpeg", iconData: Icons.favorite_border,
            width: width,
            height: height,
            onPressedFabIcon: () => {},
            left: left,),
          CardImageWithFabIcon(pathImage:"assets/img/sunset.jpeg", iconData: Icons.favorite_border,
            width: width,
            height: height,
            onPressedFabIcon: () => {},
            left: left,),
        ],
      ),
    );
  }

}