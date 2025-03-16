import 'package:facetrip/Place/model/place.dart';
import 'package:facetrip/User/model/user.dart';
import 'package:flutter/material.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewList extends StatelessWidget {
  final String userPhotoUrl;
  final String userName;
  final Place? selectedPlace;

  ReviewList({
    required this.userPhotoUrl,
    required this.userName,
    required this.selectedPlace,
  });

  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = BlocProvider.of<UserBloc>(context);

    return StreamBuilder(
      stream: userBloc.placesStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasData) {
          String? userId = _extractUserId(selectedPlace?.userOwner);
          
          return FutureBuilder(
            future: Future.wait([
              _getUserPlacesCount(userId),
              _getUserDescription(userId),
              _getUserName(userId),
              _getUserImage(userId),
            ]),
            builder: (context, AsyncSnapshot<List<dynamic>> combinedSnapshot) {
              if (combinedSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (combinedSnapshot.hasData) {
                final numberOfPlaces = combinedSnapshot.data![0] as int;
                final userDescription = combinedSnapshot.data![1] as String?;
                final nameUser = combinedSnapshot.data![2] as String?;
                final imageUser = combinedSnapshot.data![3] as String?;

                return Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 20.0, left: 20.0),
                      width: 80.0,
                      height: 80.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(imageUser!.isNotEmpty ? imageUser : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 20.0),
                            child: Text(
                              nameUser!,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: "Lato",
                                fontSize: 17.0
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 20.0),
                            child: Text(
                              "$numberOfPlaces place${numberOfPlaces > 1 ? 's' : ''}",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: "Lato",
                                fontSize: 13.0,
                                color: Color(0xFFa3a5a7)
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 20.0),
                            child: Text(
                              userDescription ?? "There is an amazing place in Sri Lankaaaa",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: "Lato",
                                fontSize: 13.0,
                                fontWeight: FontWeight.w900
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Text("User data not found.");
              }
            },
          );
        } else {
          return Text("No places found.");
        }
      },
    );
  }

  String? _extractUserId(dynamic userOwner) {
    if (userOwner is String) {
      return userOwner;
    } else if (userOwner is User) {
      return userOwner.uid;
    }
    return null;
  }

  Future<int> _getUserPlacesCount(String? userId) async {
    if (userId == null) return 0;

    try {
      final userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final myPlaces = userSnapshot.data()?['myPlaces'] as List<dynamic>? ?? [];
      return myPlaces.length;
    } catch (e) {
      print("Error fetching user places: $e");
      return 0;
    }
  }

  Future<String?> _getUserDescription(String? userId) async {
    if (userId == null) return null;

    try {
      final userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return userSnapshot.data()?['description'] as String?;
    } catch (e) {
      print("Error fetching user description: $e");
      return null;
    }
  }

  Future<String?> _getUserName(String? userId) async {
    if (userId == null) return null;

    try {
      final userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return userSnapshot.data()?['name'] as String?;
    } catch (e) {
      print("Error fetching user name: $e");
      return null;
    }
  }

  Future<String?> _getUserImage(String? userId) async {
    if (userId == null) return null;

    try {
      final userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return userSnapshot.data()?['photoURL'] as String?;
    } catch (e) {
      print("Error fetching user image: $e");
      return null;
    }
  }

}