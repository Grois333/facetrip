import 'package:flutter/material.dart';
import 'package:facetrip/Place/ui/widgets/description_place.dart';
import '/Place/ui/screens/header_appbar.dart';
import 'package:facetrip/Place/ui/widgets/review_list.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';
import 'package:facetrip/Place/model/place.dart';

class HomeTrips extends StatefulWidget {
  @override
  _HomeTripsState createState() => _HomeTripsState();
}

class _HomeTripsState extends State<HomeTrips> {
  Place? selectedPlace;

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

          // Print the selectedPlace to debug
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
                ReviewList(),
              ],
            ),
            HeaderAppBar(),
          ],
        );
      },
    );
  }
}
