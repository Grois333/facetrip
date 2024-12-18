import 'package:flutter/material.dart';
import '/widgets/floating_action_button_green.dart';

class CardImageWithFabIcon extends StatelessWidget {
  final double height;
  final double width;
  final double left;
  final String pathImage; // URL of the image from Firebase Storage
  final VoidCallback onPressedFabIcon;
  final IconData iconData;

  CardImageWithFabIcon({
    required this.pathImage,
    required this.width,
    required this.height,
    required this.onPressedFabIcon,
    required this.iconData,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      height: height,
      width: width,
      margin: EdgeInsets.only(left: left),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(pathImage), // Always treat pathImage as a network URL
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            debugPrint("Error loading image: $exception");
          },
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
