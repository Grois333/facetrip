import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facetrip/Place/model/place.dart';
import 'package:facetrip/User/model/user.dart' as userModel;
import 'package:facetrip/User/bloc/bloc_user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FloatingActionButtonGreen extends StatelessWidget {
  final IconData iconData;
  final VoidCallback onPressed;

  const FloatingActionButtonGreen({
    required this.iconData,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Color.fromARGB(255, 100, 197, 85),
      child: Icon(iconData),
    );
  }
}

class SearchTrips extends StatefulWidget {
  final UserBloc userBloc;

  SearchTrips({required this.userBloc});

  @override
  _SearchTripsState createState() => _SearchTripsState();
}

class _SearchTripsState extends State<SearchTrips> with WidgetsBindingObserver {
  List<Place> favoritePlaces = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer for lifecycle changes
    _loadFavoritePlaces();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Avoid calling _loadFavoritePlaces unnecessarily if already loaded
    if (!isLoading) {
      _loadFavoritePlaces();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadFavoritePlaces(); // Reload data when the app resumes
    }
  }

  Future<void> _loadFavoritePlaces() async {
    setState(() => isLoading = true);
    try {
      final currentUser = await widget.userBloc.currentUser();
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          final myFavoritePlaces = List<String>.from(userDoc['myFavoritePlaces'] ?? []);
          favoritePlaces = await _fetchPlaces(myFavoritePlaces);
        }
      }
    } catch (e) {
      print("Error loading favorite places: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> reloadFavoritePlaces() async {
    await _loadFavoritePlaces();
  }


  Future<List<Place>> _fetchPlaces(List<String> placePaths) async {
    final List<Place> places = [];
    for (String path in placePaths) {
      final placeDoc = await FirebaseFirestore.instance.doc(path).get();
      if (placeDoc.exists) {
        final placeData = placeDoc.data() as Map<String, dynamic>;
        places.add(
          Place(
            key: Key(placeData['id'] ?? ''),
            id: placeDoc.id,
            name: placeData['name'],
            description: placeData['description'],
            urlImage: placeData['urlImage'] ?? '',
            userOwner: userModel.User(
              key: UniqueKey(),
              uid: '',
              name: 'Unknown User',
              email: 'unknown@example.com',
              photoURL: '',
              myPlaces: [],
              myFavoritePlaces: [],
            ),
            likes: List<String>.from(placeData['likes'] ?? []),
            stars: placeData['stars'] ?? 0,
          ),
        );
      }
    }
    return places;
  }

  Future<void> _toggleLike(Place place, bool isLiked) async {
    final currentUser = await widget.userBloc.currentUser();
    if (currentUser == null) return;

    final likesList = place.likes.cast<String>();
    final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
    final placeRef = FirebaseFirestore.instance.collection('places').doc(place.id);

    setState(() {
      if (isLiked) {
        likesList.remove(currentUser.uid);
      } else {
        likesList.add(currentUser.uid);
      }
      place.likes = likesList;
    });

    await widget.userBloc.likePlace(place.id, likesList);

    if (isLiked) {
      await userRef.update({
        'myFavoritePlaces': FieldValue.arrayRemove([placeRef.path]),
      });
    } else {
      await userRef.update({
        'myFavoritePlaces': FieldValue.arrayUnion([placeRef.path]),
      });
    }

    // Reload data to reflect changes
    _loadFavoritePlaces();
  }

  Widget _buildFavoritePlaceCard(Place place) {
    return FutureBuilder<User?>(
      future: widget.userBloc.currentUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final currentUser = snapshot.data!;
        final isLiked = place.likes.contains(currentUser.uid);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)), // Rounded on all sides
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(15.0)), // Rounded on all sides
                child: Image.network(
                  place.urlImage,
                  width: double.infinity,
                  height: 250.0, // Set a fixed height to ensure full image visibility
                  fit: BoxFit.cover, // Ensure the full image is visible while maintaining aspect ratio
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      place.description,
                      style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              Icons.star,
                              color: index < place.stars ? Colors.amber : Colors.grey,
                              size: 18.0,
                            ),
                          ),
                        ),
                        FloatingActionButtonGreen(
                          iconData: isLiked ? Icons.favorite : Icons.favorite_border,
                          onPressed: () => _toggleLike(place, isLiked),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFavoritePlaces,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 150.0, // Height for the title and space
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: EdgeInsets.only(left: 16.0), // Add padding to left
                      title: const Text(
                        'My Favorite Places',
                        style: TextStyle(color: Colors.black),
                      ),
                      background: Container(color: Colors.white10),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Check if it's the last item to add extra padding
                        if (index == favoritePlaces.length - 1) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 80.0), // Adjust space above navigation bar
                            child: _buildFavoritePlaceCard(favoritePlaces[index]),
                          );
                        }
                        return _buildFavoritePlaceCard(favoritePlaces[index]);
                      },
                      childCount: favoritePlaces.length,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
