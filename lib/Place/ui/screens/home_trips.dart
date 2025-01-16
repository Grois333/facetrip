import 'package:flutter/material.dart';
import 'package:facetrip/Place/ui/widgets/description_place.dart';
import '/Place/ui/screens/header_appbar.dart';
import 'package:facetrip/Place/ui/widgets/review_list.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';
import 'package:facetrip/Place/model/place.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Firebase access

class HomeTrips extends StatefulWidget {
  @override
  _HomeTripsState createState() => _HomeTripsState();
}

class _HomeTripsState extends State<HomeTrips> {
  Place? selectedPlace;
  String userPhotoUrl = ''; // User's photo URL
  String userName = ''; // User's name
  int numberOfPlaces = 0; // Use myPlaces count

  @override
  void initState() {
    super.initState();

    // Initialize with the first place when the widget loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userBloc = BlocProvider.of<UserBloc>(context);
      userBloc.placesStream.first.then((snapshot) {
        final places = userBloc.buildPlaceObjects(snapshot.docs);
        if (places.isNotEmpty) {
          setState(() {
            selectedPlace = places.first;
          });
        }
      });

      // Get user info (photo URL, name)
      userBloc.userInfoStream.first.then((userSnapshot) {
        setState(() {
          userPhotoUrl = userSnapshot.photoURL ?? ''; // Set photo URL
          userName = userSnapshot.name ?? ''; // Set user name
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = BlocProvider.of<UserBloc>(context);

    return StreamBuilder<Place>(
      stream: userBloc.placeSelectedStream,
      builder: (context, snapshot) {
        // Update selectedPlace whenever a new place is selected
        if (snapshot.hasData) {
          selectedPlace = snapshot.data;

          // Fetch and print the user's total places count
          if (selectedPlace != null) {
            _printUserTotalPlaces(userBloc, selectedPlace!.userOwner.uid);

          }

          // Debugging the selectedPlace
          print('Selected Place: ${selectedPlace?.name}, Stars: ${selectedPlace?.stars}');
        }

        return Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
                // Pass the stars value dynamically from selectedPlace
                DescriptionPlace(
                  selectedPlace?.name ?? "Bahamas",
                  selectedPlace?.stars ?? 1, // Use stars from Firestore data
                  selectedPlace?.description ?? "Default description for the selected place.",
                ),
                // Pass user data dynamically to the ReviewList widget
                ReviewList(
                  userPhotoUrl: userPhotoUrl,
                  userName: userName,
                  selectedPlace: selectedPlace,
                ),
              ],
            ),
            HeaderAppBar(),
          ],
        );
      },
    );
  }

  // Function to fetch and print the total places count for a user
  Future<void> _printUserTotalPlaces(UserBloc userBloc, String userOwnerId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userOwnerId).get();
      final myPlaces = userDoc['myPlaces'] ?? [];
      print('User $userOwnerId has ${myPlaces.length} places in total.');
    } catch (e) {
      print('Error fetching user places: $e');
    }
  }
}
