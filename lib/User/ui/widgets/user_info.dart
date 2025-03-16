import 'package:flutter/material.dart';
import 'package:facetrip/User/model/user.dart';
import 'package:facetrip/User/ui/widgets/description_field.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfo extends StatefulWidget {
  final User user;

  const UserInfo({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  late Stream<DocumentSnapshot> userStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream to listen to user document updates
    userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProvider.of<UserBloc>(context);
    
    final userPhoto = Container(
      width: 90.0,
      height: 90.0,
      margin: const EdgeInsets.only(right: 20.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 2.0,
          style: BorderStyle.solid,
        ),
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(widget.user.photoURL.isNotEmpty ? widget.user.photoURL : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
        ),
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          userPhoto,
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: userStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    'Error loading user data',
                    style: TextStyle(color: Colors.red[400]),
                  );
                }

                // Get the current description from Firestore
                String currentDescription = '';
                if (snapshot.hasData && snapshot.data != null) {
                  Map<String, dynamic>? userData = 
                      snapshot.data!.data() as Map<String, dynamic>?;
                  currentDescription = userData?['description'] ?? '';
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 5.0),
                      child: Text(
                        widget.user.name,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Lato',
                        ),
                      ),
                    ),
                    Text(
                      widget.user.email,
                      style: const TextStyle(
                        fontSize: 15.0,
                        color: Colors.white30,
                        fontFamily: 'Lato',
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    DescriptionField(
                      uid: widget.user.uid,
                      initialText: currentDescription, // Use the current description from Firestore
                      isEditing: false,
                      onSave: (newDescription) async {
                        await userBloc.updateUserDescription(widget.user.uid, newDescription);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}