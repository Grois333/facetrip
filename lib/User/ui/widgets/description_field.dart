import 'package:facetrip/User/bloc/bloc_user.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DescriptionField extends StatefulWidget {
  final String uid;
  final String initialText;
  final Function(String) onSave;
  final bool isEditing;

  const DescriptionField({
    Key? key,
    required this.uid,
    required this.initialText,
    required this.onSave,
    required this.isEditing,
  }) : super(key: key);

  @override
  State<DescriptionField> createState() => _DescriptionFieldState();
}

class _DescriptionFieldState extends State<DescriptionField> {
  late UserBloc userBloc;
  late Stream<DocumentSnapshot> userStream;

  @override
  void initState() {
    super.initState();
    userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .snapshots();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userBloc = BlocProvider.of<UserBloc>(context);
  }

  String _getDescription(DocumentSnapshot? snapshot) {
    if (snapshot != null && snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>?;
      final description = data?['description'] as String?;
      if (description != null && description.isNotEmpty) {
        return description;
      }
    }
    return "There is an amazing place in Sri Lanka";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: userStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'Error loading description',
            style: TextStyle(
              fontSize: 13.0,
              color: Colors.red[400],
              fontFamily: 'Lato',
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            if (!widget.isEditing) {
              _showEditDialog(context);
            }
          },
          child: Text(
            _getDescription(snapshot.data),
            style: const TextStyle(
              fontSize: 13.0,
              color: Colors.white,
              fontFamily: 'Lato',
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    String latestDescription = await userBloc.getUserDescription(widget.uid);
    final TextEditingController controller = TextEditingController(
      text: latestDescription.isEmpty 
          ? "There is an amazing place in Sri Lanka"
          : latestDescription
    );
    
    return showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
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
                widget.onSave(newDescription);
              }
              Navigator.of(dialogContext).pop(); // Use dialogContext to close the dialog
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}