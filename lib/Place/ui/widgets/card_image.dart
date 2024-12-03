import 'dart:io';

import 'package:flutter/material.dart';
import '/widgets/floating_action_button_green.dart';

class  CardImageWithFabIcon extends StatelessWidget {

  final double height;
  final double width;
  double left = 20.0;
  final String pathImage;
  final VoidCallback onPressedFabIcon;
  final IconData iconData;


  CardImageWithFabIcon({
    //Key key,
    required this.pathImage,
    required this.width,
    required this.height,
    required this.onPressedFabIcon,
    required this.iconData,
    required this.left
  });

  @override
  Widget build(BuildContext context) {

    // Check if the pathImage is a file path or an asset path
    final imageProvider = pathImage.contains('assets')
        ? AssetImage(pathImage) // If it's an asset path
        : FileImage(File(pathImage)) as ImageProvider<Object>; // If it's a file path

    // TODO: implement build

    // final card = Container(
    //   height: height,
    //   width: width,
    //   margin: EdgeInsets.only(
    //     left: left

    //   ),

    //   decoration: BoxDecoration(
        
    //     // image: DecorationImage(
    //     //   fit: BoxFit.cover,
    //     //     //image: AssetImage(pathImage)
    //     //     image: AssetImage(pathImage)
    //     // ),
    //     image: 
    //     DecorationImage(
    //         image: pathImage.contains('assets')? AssetImage(pathImage):FileImage(File(pathImage)) as ImageProvider<Object> ,
    //       fit: BoxFit.cover,
    //     ),


    //     borderRadius: BorderRadius.all(Radius.circular(10.0)),
    //     shape: BoxShape.rectangle,
    //     boxShadow: <BoxShadow>[
    //       BoxShadow (
    //         color:  Colors.black38,
    //         blurRadius: 15.0,
    //         offset: Offset(0.0, 7.0)
    //       )
    //     ]

    //   ),
    // );

    final card = Container(
      height: height,
      width: width,
      margin: EdgeInsets.only(left: left),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        shape: BoxShape.rectangle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black38,
            blurRadius: 15.0,
            offset: Offset(0.0, 7.0),
          )
        ],
      ),
    );

    return Stack(
      alignment: Alignment(0.9,1.1),
      children: <Widget>[
        card,
        FloatingActionButtonGreen(iconData: iconData, onPressed: onPressedFabIcon,)
      ],
    );
  }

}