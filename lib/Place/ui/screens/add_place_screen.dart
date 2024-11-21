import 'dart:io';

import 'package:flutter/material.dart';
import 'package:facetrip/widgets/gradient_back.dart';

class AddPlaceScreen extends StatefulWidget {

  final File? image;

  AddPlaceScreen(this.image);


  @override
  State createState() {
    return _AddPlaceScreen();
  }
}

class _AddPlaceScreen extends State<AddPlaceScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
                      icon: Icon(Icons.keyboard_arrow_left, color: Colors.white, size: 45,),
                      onPressed: () {
                        Navigator.pop(context);
                      }
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}