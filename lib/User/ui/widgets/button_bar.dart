import 'package:flutter/material.dart';
import 'package:facetrip/Place/ui/screens/add_place_screen.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:facetrip/User/bloc/bloc_user.dart';
import 'package:facetrip/User/model/user.dart' as UserModel;
import 'circle_button.dart';

class ButtonsBar extends StatelessWidget {
  final VoidCallback toggleEditMode;
  final bool isEditing;
  final UserModel.User user;  // Add user parameter

  const ButtonsBar({
    Key? key,
    required this.toggleEditMode,
    required this.isEditing,
    required this.user,  // Add this parameter
  }) : super(key: key);

  Future<void> _showEditDialog(BuildContext context, UserBloc userBloc) async {
    String latestDescription = await userBloc.getUserDescription(user.uid);
    final TextEditingController controller = TextEditingController(
      text: latestDescription.isEmpty 
          ? "There is an amazing place in Sri Lanka"
          : latestDescription
    );
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Edit Description'),
        content: TextField(
          controller: controller,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            hintText: 'Enter your description',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newDescription = controller.text.trim();
              if (newDescription.isNotEmpty) {
                userBloc.updateUserDescription(user.uid, newDescription);
              }
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProvider.of<UserBloc>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          CircleButton(
            false,
            Icons.edit,
            20.0,
            isEditing ? Colors.white : const Color.fromRGBO(255, 255, 255, 0.6),
            () => _showEditDialog(context, userBloc),  // Updated to show edit dialog
          ),
          CircleButton(
            false,
            Icons.add,
            40.0,
            const Color.fromRGBO(255, 255, 255, 1),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPlaceScreen()),
              );
            },
          ),
          CircleButton(
            false,
            Icons.exit_to_app,
            20.0,
            const Color.fromRGBO(255, 255, 255, 0.6),
            () => {
              BlocProvider.of<UserBloc>(context).signOut()
            },
          ),
        ],
      ),
    );
  }
}