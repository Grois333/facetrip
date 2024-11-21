import 'package:flutter/material.dart';

class CircleButton extends StatefulWidget {
  final VoidCallback onPressed;
  bool mini;
  var icon;
  double iconSize;
  var color;

  CircleButton(this.mini, this.icon, this.iconSize, this.color, @required this.onPressed);

  @override
  State<StatefulWidget> createState() {
    return _CircleButton();
  }

}

class _CircleButton extends State<CircleButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,  // Make the button tappable
      child: Container(
        width: widget.mini ? widget.iconSize : widget.iconSize + 30,  // Increase size for larger buttons
        height: widget.mini ? widget.iconSize : widget.iconSize + 30, // Equal width and height for a circle
        decoration: BoxDecoration(
          shape: BoxShape.circle,  // Ensures the container is circular
          color: widget.color, // The background color of the button
        ),
        child: Center(  // Center the child widget (icon) inside the container
          child: Padding(
            padding: EdgeInsets.all(widget.mini ? 0 : 8.0),  // More padding for larger buttons
            child: Icon(
              widget.icon,
              size: widget.iconSize,  // Icon size
              color: Colors.indigo,  // Icon color is now indigo
            ),
          ),
        ),
      ),
    );
  }
}

// class _CircleButton extends State<CircleButton> {

//   void onPressedButton() {

//   }

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(

//         child: FloatingActionButton(
//           backgroundColor: widget.color,
//           mini: widget.mini,
//           onPressed: widget.onPressed,
//           child: Icon(
//             widget.icon,
//             size: widget.iconSize,
//             color: Color(0xFF4268D3),
//           ),
//           heroTag: null,
//         )

        
//     );
//   }
// }