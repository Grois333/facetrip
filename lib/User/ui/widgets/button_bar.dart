import 'dart:io';
import 'package:facetrip/Place/ui/screens/add_place_screen.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';
import 'circle_button.dart';
import 'package:image_picker/image_picker.dart';

class ButtonsBar extends StatefulWidget {
  final VoidCallback toggleEditMode; // Callback to notify UserInfo

  ButtonsBar({required this.toggleEditMode});

  @override
  _ButtonsBarState createState() => _ButtonsBarState();
}

class _ButtonsBarState extends State<ButtonsBar> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          // Toggle edit mode
          CircleButton(
            false,
            Icons.description,
            20.0,
            isEditing ? Colors.white : Color.fromRGBO(255, 255, 255, 0.6),
            () {
              setState(() {
                isEditing = !isEditing;
              });
              widget.toggleEditMode();
            },
          ),

          // Add Place Button
          CircleButton(
            false,
            Icons.add,
            40.0,
            Color.fromRGBO(255, 255, 255, 1),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPlaceScreen()),
              );
            },
          ),

          // Logout Button
          CircleButton(
            false,
            Icons.exit_to_app,
            20.0,
            Color.fromRGBO(255, 255, 255, 0.6),
            () => {
              BlocProvider.of<UserBloc>(context).signOut()
            },
          ),
        ],
      ),
    );
  }
}
