import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text; // The display name or email of the user
  final String? subtitle; // The last message from the user
  final void Function()? onTap; // Tap callback for navigation

  const UserTile({
    super.key, 
    required this.text, 
    this.subtitle,  // Optional subtitle for the last message
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiary,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 3,
          horizontal: 25,
        ),
        padding: EdgeInsets.all(13),
        child: Row(
          children: [
            const Icon(Icons.person), // User icon
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text, // User's display name or email
                    style: Theme.of(context).textTheme.bodyLarge, // bodyLarge instead of bodyText1
                  ),
                  if (subtitle != null) // Show the last message if it exists
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith( // bodyMedium instead of bodyText2
                        color: theme.colorScheme.primary, // Light grey color for the last message
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
