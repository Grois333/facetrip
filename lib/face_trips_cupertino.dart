import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'Place/ui/screens/home_trips.dart';
import 'Place/ui/screens/search_trips.dart';
import '/User/ui/screens/profile_trips.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';

final userBloc = UserBloc();
final GlobalKey<SearchTripsState> searchTripsKey = GlobalKey();

class FaceTripsCupertino extends StatefulWidget {
  @override
  _FaceTripsCupertinoState createState() => _FaceTripsCupertinoState();
}

class _FaceTripsCupertinoState extends State<FaceTripsCupertino> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Color(0x33FFFFFF),
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 8),
                child: Icon(Icons.home, color: Colors.indigo),
              ),
              label: ""
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 8),
                child: Icon(Icons.favorite, color: Colors.indigo),
              ),
              label: ""
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 8),
                child: Icon(Icons.person, color: Colors.indigo),
              ),
              label: ""
            ),
          ],
          onTap: (index) {
            if (index == 1) {
              searchTripsKey.currentState?.reloadFavoritePlaces();
            }
            setState(() {
              _currentIndex = index;
            });
          },
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
                builder: (BuildContext context) => SearchTrips(key: searchTripsKey, userBloc: userBloc),
              );
            case 2:
              return CupertinoTabView(
                builder: (BuildContext context) {
                  return BlocProvider<UserBloc>(
                    bloc: UserBloc(),
                    child: ProfileTrips(),
                  );
                },
              );
            default:
              return CupertinoTabView(
                builder: (BuildContext context) => HomeTrips(),
              );
          }
        },
      ),
    );
  }
}