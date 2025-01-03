import 'package:flutter/material.dart';

class UserTextfield extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextStyle? style; // Add style parameter

  const UserTextfield({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.focusNode,
    this.style, // Include style in the constructor
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        style: style ?? TextStyle(
          fontSize: 16.0,
          color: theme.colorScheme.onSurface, // Fallback text color based on theme
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          fillColor: theme.brightness == Brightness.light
              ? Colors.white
              : Colors.grey[800] ,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 13.0,
            color: theme.brightness == Brightness.light
              ? Colors.grey
              : Colors.grey ,
          ),
        ),
      ),
    );
  }
}
