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
  Widget build(BuildContext context) {
    final UserBloc userBloc = BlocProvider.of<UserBloc>(context);

    return StreamBuilder<Place>(
      stream: userBloc.placeSelectedStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          selectedPlace = snapshot.data;
        }

        return Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
                DescriptionPlace(
                  selectedPlace?.name ?? "Bahamas",
                  4,
                  selectedPlace?.description ??
                      "Default description for the selected place.",
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
