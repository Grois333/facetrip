import 'dart:io';

import 'package:facetrip/Place/ui/screens/add_place_screen.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';
import 'circle_button.dart';

class ButtonsBar extends StatelessWidget {
  late UserBloc userBloc;

  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of(context);

    return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 0.0,
            vertical: 10.0
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            //Cambiar la contraseña
            CircleButton(
              false, 
              Icons.vpn_key, 
              20.0,
              Color.fromRGBO(255, 255, 255, 0.6)
                , () => {

                }),
            //Añadiremos un nuevo lugar
            CircleButton(
              false, 
              Icons.add, 
              40.0, 
              Color.fromRGBO(255, 255, 255, 1),
              ()  {
                File? image = null;
                Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) => AddPlaceScreen(image)));
              }),

            //Cerrar Sesión
            CircleButton(
              false, 
              Icons.exit_to_app, 
              20.0, 
              Color.fromRGBO(255, 255, 255, 0.6),
                    () => {
                      userBloc.signOut()
                    }),

          ],
        )
    );
  }

}