import 'package:flutter/material.dart';
import 'package:facetrip/User/model/user.dart';
import 'package:facetrip/User/ui/widgets/user_info.dart';
import 'package:facetrip/User/ui/widgets/button_bar.dart';

class ProfileHeader extends StatelessWidget {
  final User user;

  const ProfileHeader({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50.0),
      child: Column(
        children: <Widget>[
          const Align(
            alignment: Alignment.centerLeft, // Aligns the text to the left
            child: Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Text(
                'Profile',
                style: TextStyle(
                  fontFamily: 'Lato',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                ),
              ),
            ),
          ),
          UserInfo(user: user),
          ButtonsBar(
            toggleEditMode: () {},
            isEditing: false,
            user: user,
          ),
        ],
      ),
    );
  }
}
