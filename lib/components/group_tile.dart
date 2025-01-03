import 'package:flutter/material.dart';

class GroupTile extends StatelessWidget {
  final String text;
  final String groupId; // Add groupId to identify the group
  final void Function()? onTap;
  final void Function()? onEdit;
  final void Function()? onDelete;

  const GroupTile({
    super.key,
    required this.text,
    required this.groupId,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context); // Get the theme context

    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        _showOptionsDialog(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiary, // Matching background color to UserTile
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 25),
        padding: const EdgeInsets.all(20), // Same padding as UserTile
        child: Row(
          children: [
            const Icon(Icons.group), // Group icon
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text, // Display group name
                    style: theme.textTheme.bodyLarge, // Consistent with UserTile
                  ),
                  // You can add an optional subtitle for last activity or details if needed
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Squared corners
          ),
          title: const Text('Actions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Group'),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  if (onEdit != null) onEdit!(); // Call onEdit if it's provided
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Group'),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  if (onDelete != null) onDelete!(); // Call onDelete if it's provided
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
