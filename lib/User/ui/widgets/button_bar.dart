import 'package:flutter/material.dart';
import 'package:facetrip/Place/ui/screens/add_place_screen.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';
import 'circle_button.dart';

class ButtonsBar extends StatelessWidget {
  final VoidCallback toggleEditMode;
  final bool isEditing;

  const ButtonsBar({
    Key? key,
    required this.toggleEditMode,
    required this.isEditing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          CircleButton(
            false,
            Icons.edit,
            20.0,
            isEditing ? Colors.white : const Color.fromRGBO(255, 255, 255, 0.6),
            toggleEditMode,
          ),
          CircleButton(
            false,
            Icons.add,
            40.0,
            const Color.fromRGBO(255, 255, 255, 1),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPlaceScreen()),
              );
            },
          ),
          CircleButton(
            false,
            Icons.exit_to_app,
            20.0,
            const Color.fromRGBO(255, 255, 255, 0.6),
            () => {
              BlocProvider.of<UserBloc>(context).signOut()
            },
          ),
        ],
      ),
    );
  }
}