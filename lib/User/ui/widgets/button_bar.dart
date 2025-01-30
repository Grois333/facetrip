import 'dart:io';

import 'package:facetrip/Place/ui/screens/add_place_screen.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';
import 'circle_button.dart';
import 'package:image_picker/image_picker.dart';

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
              Icons.description, 
              20.0,
              Color.fromRGBO(255, 255, 255, 0.6)
                , () => {

                }),

            //Añadiremos un nuevo lugar
            //  CircleButton(
            //   false,
            //   Icons.add,
            //   40.0,
            //   Color.fromRGBO(255, 255, 255, 1),
            //   () async {
            //     try {
            //       // Pick the image using the ImagePicker package
            //       final ImagePicker picker = ImagePicker();
            //       final XFile? image = await picker.pickImage(source: ImageSource.camera);

            //       // Check if an image was picked
            //       if (image != null) {
            //         // Use `push` instead of replacing the screen
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (BuildContext context) => AddPlaceScreen(
            //               imageFile: File(image.path),
            //             ),
            //           ),
            //         );
            //       } else {
            //         print("No image picked");
            //       }
            //     } catch (e) {
            //       print("Error picking image: $e");
            //     }
            //   },
            // ),
            CircleButton(
              false,
              Icons.add,
              40.0,
              Color.fromRGBO(255, 255, 255, 1),

              (){
                // Navigate to AddPlaceScreen when the icon is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddPlaceScreen(), // Navigate to AddPlaceScreen
                  ),
                );
              },

              // () async {
              //   try {
              //     // Pick the image using the ImagePicker package
              //     final ImagePicker picker = ImagePicker();
              //     final XFile? image = await picker.pickImage(source: ImageSource.camera);

              //     // Check if an image was picked
              //     if (image != null) {
              //       print("Image path: ${image.path}"); // Add this line to verify the image path.

              //       // Make sure to navigate with the correct context and pass the File(image.path)
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (BuildContext context) => AddPlaceScreen(
              //             imageFile: File(image.path), // Ensure File is passed correctly
              //           ),
              //         ),
              //       );
              //     } else {
              //       print("No image picked");
              //     }
              //   } catch (e) {
              //     print("Error picking image: $e");
              //   }
              // },

            ),


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