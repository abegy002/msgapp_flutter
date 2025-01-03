import 'package:flutter/material.dart';
import 'package:msgapp_flutter/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import intl package

class GroupChatBubble extends StatelessWidget {
  final String userEmail;
  final String message;
  final bool isCurrentUser;
  final DateTime timestamp; // Accept timestamp as a String

  const GroupChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.userEmail,
    required this.timestamp, // Include timestamp
    required Color textColor, Color? backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

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
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Display the email of the user who sent the message
          Text(
            userEmail,
            style: TextStyle(
              fontSize: 12,
              color: isCurrentUser
                  ? Colors.white70
                  : (isDarkMode ? Colors.white70 : Colors.black87),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4), // Add space between email and message
          // Display the actual message
          Text(
            message,
            style: TextStyle(
              color: isCurrentUser
                  ? Colors.white
                  : (isDarkMode ? Colors.white : Colors.black),
            ),
          ),
          const SizedBox(height: 3), // Add some space between message and timestamp
          // Display the formatted timestamp
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
