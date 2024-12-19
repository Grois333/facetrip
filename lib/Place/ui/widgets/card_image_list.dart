import 'package:facetrip/Place/model/place.dart';
import 'package:facetrip/User/model/user.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/Place/ui/widgets/card_image.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';

class CardImageList extends StatefulWidget {
  final User user;

  CardImageList(this.user);

  @override
  _CardImageListState createState() => _CardImageListState();
}

class _CardImageListState extends State<CardImageList> {
  late UserBloc userBloc;

  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of<UserBloc>(context);

    return Container(
      margin: const EdgeInsets.only(top: 50.0),
      height: 350.0,
      child: StreamBuilder(
        stream: userBloc.placesStream,
        builder: (context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasData) {
                return listViewPlaces(userBloc.buildPlaceObjects(snapshot.data.docs));
              } else {
                return const Center(child: Text('No places found'));
              }
            default:
              return const Center(child: Text('Unexpected state'));
          }
        },
      ),
    );
  }

  Widget listViewPlaces(List<Place> places) {
    return ListView(
      padding: const EdgeInsets.only(top: 25.0, bottom: 100.0),
      scrollDirection: Axis.horizontal,
      children: places.map((place) {
        return StatefulBuilder(
          builder: (context, setState) {
            return CardImageWithFabIcon(
              pathImage: place.urlImage,
              width: 300.0,
              height: 250.0,
              left: 20.0,
              iconData: place.liked ? Icons.favorite : Icons.favorite_border,
              onPressedFabIcon: () {
                setState(() {
                  place.liked = !place.liked; // Toggle liked state
                  userBloc.likePlace(place.id, place.liked); // Update Firestore
                });
              },
            );
          },
        );
      }).toList(),
    );
  }



}
