import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';
import 'package:facetrip/User/model/user.dart';
import 'package:facetrip/User/ui/widgets/user_info.dart';
import 'package:facetrip/User/ui/widgets/button_bar.dart';

class ProfileHeader extends StatefulWidget {
  ProfileHeader({Key? key}) : super(key: key);

  @override
  _ProfileHeaderState createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  final UserBloc userBloc = UserBloc();
  bool _isEditing = false; // Track edit mode
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _descriptionController;
  late User _user;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Toggle edit mode
  void toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Profile',
                style: TextStyle(
                  fontFamily: 'Lato',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                ),
              ),
              IconButton(
                icon: Icon(_isEditing ? Icons.check : Icons.edit, color: Colors.white),
                onPressed: toggleEditMode,
              ),
            ],
          ),
          StreamBuilder<firebase_auth.User?>(
            stream: userBloc.authStatus,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (!snapshot.hasData || snapshot.hasError) {
                return _buildNotLoggedInUI();
              } else {
                return _buildProfileUI(snapshot.data!);
              }
            },
          ),
        ],
      ),
    );
  }

  /// Widget to show when user is not logged in
  Widget _buildNotLoggedInUI() {
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 50.0),
      child: const Column(
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 10),
          Text(
            "No se pudo cargar la información. Haz login",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// Widget to show user profile data with editable fields
  Widget _buildProfileUI(firebase_auth.User firebaseUser ) {
    _user = User(
      key: Key(firebaseUser .uid),
      uid: firebaseUser .uid,
      name: firebaseUser .displayName ?? "No Name",
      email: firebaseUser .email ?? "No Email",
      photoURL: firebaseUser .photoURL ?? "",
      myPlaces: [],
      myFavoritePlaces: [],
    );

    // Set initial values for editing
    _descriptionController.text = "There is an amazing place in Sri Lanka"; // Default description

    return Column(
      children: <Widget>[
        UserInfo(
          user: _user,
          editMode: _isEditing,
          descriptionController: _descriptionController,
        ),
        ButtonsBar(toggleEditMode: toggleEditMode), // Pass toggleEditMode
      ],
    );
  }

  /// Editable text fields
  Widget _buildEditableFields() {
    return Column(
      children: [
        // Only the description field is editable
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: "Description"),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // TODO: Implement save logic
            print("Save changes: Description = ${_descriptionController.text}");
            toggleEditMode(); // Exit edit mode after saving
          },
          child: const Text("Save Changes"),
        ),
      ],
    );
  }


}
