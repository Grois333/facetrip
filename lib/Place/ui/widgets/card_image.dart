import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '/widgets/floating_action_button_green.dart';

class CardImageWithFabIcon extends StatelessWidget {
  final double height;
  final double width;
  final double left;
  final String pathImage; // URL of the image from Firebase Storage
  final VoidCallback onPressedFabIcon;
  final IconData iconData;
  final bool isNetworkImage; // New flag to differentiate image source

  CardImageWithFabIcon({
    required this.pathImage,
    required this.width,
    required this.height,
    required this.onPressedFabIcon,
    required this.iconData,
    required this.left,
    this.isNetworkImage = true, // Default to network image
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      height: height,
      width: width,
      margin: EdgeInsets.only(left: left),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: isNetworkImage
              ? CachedNetworkImageProvider(pathImage) // Cached for network images
              : AssetImage(pathImage) as ImageProvider, // Use AssetImage for local images
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        shape: BoxShape.rectangle,
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 15.0,
            offset: Offset(0.0, 7.0),
          ),
        ],
      ),
    );

    return Stack(
      alignment: Alignment(0.9, 1.1),
      children: <Widget>[
        card,
        FloatingActionButtonGreen(
          iconData: iconData,
          onPressed: onPressedFabIcon,
        ),
      ],
    );
  }
}
