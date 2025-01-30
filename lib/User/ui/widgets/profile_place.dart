import 'package:cached_network_image/cached_network_image.dart';
import 'package:facetrip/Place/model/place.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/User/ui/widgets/profile_place_info.dart';

class ProfilePlace extends StatelessWidget {
  final Place place;
  final Function(String) onDelete; // Add onDelete callback

  ProfilePlace({required this.place, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProvider.of<UserBloc>(context); // Get the userBloc from context

    final photoCard = Container(
      margin: EdgeInsets.only(top: 10.0, bottom: 70.0),
      height: 220.0,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: CachedNetworkImageProvider(place.urlImage), // Use cached images
        ),
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        color: Colors.grey,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black38,
            blurRadius: 10.0,
            offset: Offset(0.0, 5.0),
          ),
        ],
      ),
    );

    return Stack(
      alignment: Alignment(0.0, 0.8),
      children: <Widget>[
        photoCard,
        ProfilePlaceInfo(
          place: place,
          userBloc: userBloc,
          onDelete: onDelete, // Pass the callback to ProfilePlaceInfo
        ),
      ],
    );
  }
}
