import 'package:cloud_firestore/cloud_firestore.dart';
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
        // Determine if the current user has liked the place
        final isLiked = place.likes.contains(widget.user.uid);

        return GestureDetector(
          onTap: () {
            userBloc.placeSelectedSink.add(place); // Send the tapped place
          },
          child: CardImageWithFabIcon(
            pathImage: place.urlImage,
            width: 300.0,
            height: 250.0,
            left: 20.0,
            iconData: isLiked ? Icons.favorite : Icons.favorite_border, // Update based on likes

            onPressedFabIcon: () async {
              final currentUser = widget.user.uid;

              if (currentUser != null) {
                setState(() {
                  final likesList = place.likes.cast<String>();

                  // Toggle like state
                  if (likesList.contains(currentUser)) {
                    likesList.remove(currentUser); // Unlike
                    place.liked = false; // Update the local state
                  } else {
                    likesList.add(currentUser); // Like
                    place.liked = true; // Update the local state
                  }

                  place.likes = likesList; // Update the likes list
                });

                // Sync the updated likes list to Firestore
                await userBloc.likePlace(place.id, place.likes.cast<String>());

                // Update the current user's `myFavoritePlaces` array in Firestore
                try {
                  // Fetch the user document reference
                  final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser);
                  final userDoc = await userRef.get();

                  if (!userDoc.exists) {
                    print("User document not found for UID: $currentUser");
                    return;
                  }

                  // Fetch the place document reference
                  final placeRef = FirebaseFirestore.instance.collection('places').doc(place.id);
                  final placeDoc = await placeRef.get();

                  if (!placeDoc.exists) {
                    print("Place document not found for place ID: ${place.id}");
                    return;
                  }

                  // Add or remove the place path in `myFavoritePlaces`
                  if (place.liked) {
                    // Add to `myFavoritePlaces`
                    await userRef.update({
                      'myFavoritePlaces': FieldValue.arrayUnion([placeRef.path])
                    });
                    print("Added to myFavoritePlaces: ${placeRef.path}");
                  } else {
                    // Remove from `myFavoritePlaces`
                    await userRef.update({
                      'myFavoritePlaces': FieldValue.arrayRemove([placeRef.path])
                    });
                    print("Removed from myFavoritePlaces: ${placeRef.path}");
                  }
                } catch (e) {
                  print("Error updating myFavoritePlaces: $e");
                }

              }
            },

          ),
        );
      }).toList(),
    );
  }



}
