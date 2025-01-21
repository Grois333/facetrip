import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'Place/ui/screens/home_trips.dart';
import 'Place/ui/screens/search_trips.dart';
import '/User/ui/screens/profile_trips.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';

class FaceTripsCupertino extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Color(0x33FFFFFF),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.indigo),
              label: ""
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite, color: Colors.indigo),
              label: ""
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Colors.indigo),
              label: ""
            ),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          switch (index) {
            case 0:
              return CupertinoTabView(
                builder: (BuildContext context) {
                    return BlocProvider(
                            bloc: UserBloc(),
                            child: HomeTrips(),
                    );
                },
              );
            case 1:
              return CupertinoTabView(
                builder: (BuildContext context) => SearchTrips(),
              );
            case 2:
              return CupertinoTabView(
                //builder: (BuildContext context) => ProfileTrips(),
                builder: (BuildContext context) {
                  return BlocProvider<UserBloc>(
                    bloc: UserBloc(),
                    child: ProfileTrips(),
                  );
                },
              );
            default:
              // Handle any unexpected index values (although unlikely in your case)
              return CupertinoTabView(
                builder: (BuildContext context) => HomeTrips(), // Or any default screen
              );
          }
        },
      ),
    );
  }
}