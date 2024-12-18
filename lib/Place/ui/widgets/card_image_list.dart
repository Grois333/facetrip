import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/Place/ui/widgets/card_image.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';

class CardImageList extends StatelessWidget {
  late UserBloc userBloc;

  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of<UserBloc>(context);

    return Container(
      margin: const EdgeInsets.only(top: 50.0), // Adds space above the list
      height: 350.0,
      child: StreamBuilder(
        stream: userBloc.placesStream,
        builder: (context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.active:
            case ConnectionState.done:
              return listViewPlaces(userBloc.buildPlaces(snapshot.data.docs));
            default:
              return Center(child: Text('Unexpected state'));
          }
        },
      ),
    );
  }

  Widget listViewPlaces(List<CardImageWithFabIcon> placesCard) {
    return ListView(
      padding: const EdgeInsets.only(top: 25.0, bottom: 100.0), // Space above and below the items
      scrollDirection: Axis.horizontal,
      children: placesCard,
    );
  }
}
