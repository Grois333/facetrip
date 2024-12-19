import 'package:flutter/material.dart';

class FloatingActionButtonGreen extends StatefulWidget {
  final IconData iconData; // Icon passed dynamically
  final VoidCallback onPressed;

  FloatingActionButtonGreen({
    required this.iconData,
    required this.onPressed,
  });

  @override
  State<StatefulWidget> createState() {
    return _FloatingActionButtonGreen();
  }
}

class _FloatingActionButtonGreen extends State<FloatingActionButtonGreen> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF11DA53),
      mini: true,
      tooltip: "Fav",
      onPressed: widget.onPressed, // Call the provided callback
      child: Icon(widget.iconData), // Use the passed iconData here
      heroTag: null,
    );
  }
}
