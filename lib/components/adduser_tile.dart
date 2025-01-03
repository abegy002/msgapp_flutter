import 'package:flutter/material.dart';

class AddUserTile extends StatelessWidget {
  final String text; // The display name or email of the user
  final String? subtitle; // The last message from the user (optional)
  final void Function()? onTap; // Tap callback for navigation
  final Widget trailing; // Trailing widget, e.g., a button
  final Widget leading; // Leading widget, such as user profile picture

  const AddUserTile({
    super.key,
    required this.text,
    this.subtitle, // Optional subtitle for the last message
    required this.onTap,
    required this.trailing, // Trailing widget is required
    required this.leading, // Leading widget is required
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
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            leading, // Leading widget passed dynamically
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text, // User's display name or email
                    style: Theme.of(context).textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis, // Handle overflow
                    maxLines: 1, // Limit to a single line
                  ),
                  if (subtitle != null) // Show the last message if it exists
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary, // Light grey color for the last message
                      ),
                      overflow: TextOverflow.ellipsis, // Handle overflow
                      maxLines: 1, // Limit to a single line
                    ),
                ],
              ),
            ),
            trailing, // Trailing widget, dynamically passed
          ],
        ),
      ),
    );
  }
}
