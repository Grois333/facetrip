import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facetrip/Place/model/place.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';
import 'package:flutter/material.dart';
import 'package:facetrip/widgets/floating_action_button_green.dart';

class ProfilePlaceInfo extends StatefulWidget {
  final Place place;
  final UserBloc userBloc;
  final Function(String) onDelete; // Callback to update the UI after deletion

  ProfilePlaceInfo({
    required this.place,
    required this.userBloc,
    required this.onDelete, // Pass the function to remove the item
  });

  @override
  _ProfilePlaceInfoState createState() => _ProfilePlaceInfoState();
}

class _ProfilePlaceInfoState extends State<ProfilePlaceInfo> {
  late bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    final currentUser = await widget.userBloc.currentUser();
    if (currentUser != null) {
      setState(() {
        isLiked = widget.place.likes.contains(currentUser.uid);
      });
    }
  }

  Future<void> _toggleLike() async {
    final currentUser = await widget.userBloc.currentUser();
    if (currentUser != null) {
      setState(() {
        final likesList = widget.place.likes.cast<String>();

        if (isLiked) {
          likesList.remove(currentUser.uid);
        } else {
          likesList.add(currentUser.uid);
        }

        widget.place.likes = likesList;
        isLiked = !isLiked;
      });

      widget.userBloc
          .likePlace(widget.place.id, widget.place.likes.cast<String>());

      final userRef =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      final placeRef =
          FirebaseFirestore.instance.collection('places').doc(widget.place.id);

      if (isLiked) {
        await userRef.update({
          'myFavoritePlaces': FieldValue.arrayUnion([placeRef.path]),
        });
      } else {
        await userRef.update({
          'myFavoritePlaces': FieldValue.arrayRemove([placeRef.path]),
        });
      }
    }
  }

  Future<void> _deletePlace() async {
    try {
      await FirebaseFirestore.instance
          .collection('places')
          .doc(widget.place.id)
          .delete();
      widget.onDelete(widget.place.id); // Notify parent widget to update UI
    } catch (e) {
      print("Error deleting place: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Dismissible(
      key: Key(widget.place.id), // Unique key for the item
      direction: DismissDirection.horizontal, // Allow swipe left or right
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      onDismissed: (direction) {
        _deletePlace(); // Remove from Firestore
      },
      child: Stack(
        alignment: Alignment(0.8, 1.25),
        children: <Widget>[
          Container(
            width: screenWidth * 0.65,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 5.0),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.place.name,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.place.description,
                          style: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 0.4),
                            fontFamily: 'Lato',
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2, // Limit to 2 lines
                          overflow: TextOverflow
                              .ellipsis, // Show ellipsis if text overflows
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < (widget.place.stars ?? 0)
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 20.0,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          FloatingActionButtonGreen(
            iconData: isLiked ? Icons.favorite : Icons.favorite_border,
            onPressed: _toggleLike,
          ),
        ],
      ),
    );
  }
}
