import 'package:flutter/material.dart';
import 'package:msgapp_flutter/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Correct import for intl package

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final DateTime timestamp; // Add a timestamp field

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.timestamp,
    required Color backgroundColor,
    required Color textColor,
    required BorderRadius borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    // Format the timestamp using intl package
    String formattedDate = DateFormat('hh:mm a').format(timestamp);

    return Container(
      decoration: BoxDecoration(
        color: isCurrentUser
            ? (isDarkMode ? Colors.green.shade600 : Colors.green.shade600)
            : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(9),
      margin: const EdgeInsets.symmetric(vertical: 0.5, horizontal: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
        children: [
          Text(
            message,
            style: TextStyle(
              color: isCurrentUser
                  ? Colors.white
                  : (isDarkMode ? Colors.white : Colors.black),
            ),
          ),
          const SizedBox(height: 3), // Add some spacing between message and date
          Text(
            formattedDate,
            style: TextStyle(
              color: isCurrentUser
                  ? Colors.white70
                  : (isDarkMode ? Colors.white70 : Colors.black54),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
