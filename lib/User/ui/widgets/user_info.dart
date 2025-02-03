import 'package:facetrip/User/model/user.dart';
import 'package:flutter/material.dart';

class UserInfo extends StatelessWidget {
  final User user;
  final bool editMode;
  final TextEditingController descriptionController;

  UserInfo({
    Key? key,
    required this.user,
    required this.editMode,
    required this.descriptionController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          image: NetworkImage(user.photoURL),
        ),
      ),
    );

    final userInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Name (non-editable)
        Container(
          margin: const EdgeInsets.only(bottom: 5.0),
          child: Text(
            user.name,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Lato',
            ),
          ),
        ),
        // Email (non-editable)
        Text(
          user.email,
          style: const TextStyle(
            fontSize: 15.0,
            color: Colors.white30,
            fontFamily: 'Lato',
          ),
        ),
        const SizedBox(height: 5.0), // Spacing before the description

        // Description: Editable only in edit mode, but always visible
        editMode
            ? _buildEditableTextField(descriptionController, "Description")
            : Text(
                descriptionController.text.isNotEmpty
                    ? descriptionController.text
                    : "There is an amazing place in Sri Lanka", // Default text
                style: const TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                  fontFamily: 'Lato',
                ),
              ),
      ],
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        children: <Widget>[userPhoto, userInfo],
      ),
    );
  }

  /// Editable text field for the description
  Widget _buildEditableTextField(TextEditingController controller, String label) {
    return SizedBox(
      width: 200,
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white30),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
