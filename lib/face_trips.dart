import 'package:flutter/material.dart';
import 'Place/ui/screens/home_trips.dart';
import 'Place/ui/screens/search_trips.dart';
import '/User/ui/screens/profile_trips.dart';

class FaceTrips extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FaceTrips();
  }

}

class _FaceTrips extends State<FaceTrips> {
  int indexTap = 0;
  final List<Widget> widgetsChildren = [
    HomeTrips(),
    SearchTrips(),
    ProfileTrips()
  ];

  void onTapTapped(int index){

    setState(() {
      indexTap = index;
    });

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build


    return  Scaffold(
      body: widgetsChildren[indexTap],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white,
          primaryColor: Colors.purple
        ),
        child: BottomNavigationBar(
          onTap: onTapTapped,
          currentIndex: indexTap,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "",
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: "",
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "",
              ),
            ]
        ),
      ),
    );
  }

}