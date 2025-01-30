import 'package:facetrip/User/model/user.dart';
import 'package:flutter/material.dart';

class UserInfo extends StatelessWidget {

  User user;

  

  UserInfo(@required this.user);

  @override
  Widget build(BuildContext context) {

    final userPhoto = Container(
      width: 90.0,
      height: 90.0,
      margin: EdgeInsets.only(
          right: 20.0
      ),
      decoration: BoxDecoration(
          border: Border.all(
              color: Colors.white,
              width: 2.0,
              style: BorderStyle.solid
          ),
          shape: BoxShape.circle,
          image: DecorationImage(
              fit: BoxFit.cover,
              //image: AssetImage(user.photoURL)
            image: NetworkImage(user.photoURL)
          )
      ),
    );

    final userInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(
                bottom: 5.0
            ),
            child: Text(
                user.name,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Lato',
                )
            )
        ),
        Text(
            user.email,
            style: TextStyle(
                fontSize: 15.0,
                color: Colors.white30,
                fontFamily: 'Lato'
            )
        ),
        SizedBox(height: 5.0), // Adds spacing before the editable text
        Text(
          "There is an amazing place in Sri Lanka",
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.normal,
            color: Colors.white, // White text like the username
            fontFamily: 'Lato',
          ),
        )
      ],
    );

    return Container(
      margin: EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 0.0
      ),
      child: Row(
        children: <Widget>[
          userPhoto,
          userInfo
        ],
      ),
    );
  }

}