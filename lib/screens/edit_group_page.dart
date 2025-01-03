import 'package:flutter/material.dart';
import 'package:msgapp_flutter/services/chat/group_chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditGroupPage extends StatefulWidget {
  final String groupId;

  const EditGroupPage({super.key, required this.groupId});

  @override
  _EditGroupPageState createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  final GroupChatService _groupChatService = GroupChatService();
  final TextEditingController _groupNameController = TextEditingController();
  bool _isLoading = false;
  bool _isCreator = false; // Track if the current user is the group creator
  Map<String, String> _groupMembers = {}; // Map of email to userId
  String? _groupOwnerEmail; // Store group owner email
  String? _groupOwnerId; // Store group owner ID

  @override
  void initState() {
    super.initState();
    _loadGroupData();
  }

  // Load the group data, including members and creator info
  void _loadGroupData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load the group data, including members and creator info
      final group = await _groupChatService.getGroupById(widget.groupId);
      _groupNameController.text = group.name ?? "Unknown Group";
      _isCreator = group.owner == await _groupChatService.getCurrentUserId(); // Check if the current user is the creator

      // Fetch emails for each member and store them along with userId
      for (var memberId in group.members) {
        final memberEmail = await _getEmailForMember(memberId);
        setState(() {
          _groupMembers[memberEmail] = memberId;  // Store both email and userId
        });
      }

      // Fetch owner email and ID separately
      final ownerEmail = await _getEmailForMember(group.owner);
      setState(() {
        _groupOwnerEmail = ownerEmail;
        _groupOwnerId = group.owner; // Store owner ID for later use
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error loading group data")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

    void _updateGroup() async {
    if (_groupNameController.text.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _groupChatService.updateGroup(widget.groupId, _groupNameController.text);
      Navigator.pop(context); // Return to the previous page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error updating group")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Get email for a member from the 'Users' collection
  Future<String> _getEmailForMember(String memberId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance.collection('Users').doc(memberId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return data['email'] ?? 'Unknown Email'; // Default email if not found
      }
    } catch (e) {
      print("Error fetching email: $e");
    }
    return 'Unknown Email';
  }

  // Remove member from the group
  void _removeMember(String memberEmail) async {
    final memberId = _groupMembers[memberEmail]; // Find member ID by email

    if (memberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Member not found")),
      );
      return;
    }

    // Check if the member is the group owner
    if (memberId == _groupOwnerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You cannot remove the group owner")),
      );
      return; // Do not proceed with removal
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Remove the member from Firestore
      await _groupChatService.removeMemberFromGroup(widget.groupId, memberId);

      // Remove the member from the local list as well
      setState(() {
        _groupMembers.remove(memberEmail); // Remove from the local map
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Member removed")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error removing member")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

@override
Widget build(BuildContext context) {
  final ThemeData theme = Theme.of(context);

  return Scaffold(
    backgroundColor: theme.colorScheme.background,
    appBar: AppBar(
      title: const Text('Edit Group'),
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      foregroundColor: Colors.grey,
    ),
    body: SingleChildScrollView(  // Wrap everything in a SingleChildScrollView
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (_isLoading) 
            const Center(child: CircularProgressIndicator()),
          if (!_isLoading) 
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: UnderlineInputBorder(),
              ),
            ),
          const SizedBox(height: 20),
          if (_groupOwnerEmail != null) 
            Card(
              elevation: 5,
              margin: const EdgeInsets.only(bottom: 16.0),
              color: Colors.green,
              child: ListTile(
                leading: Icon(Icons.star, color: Colors.yellow.shade700),
                title: Text(
                  '$_groupOwnerEmail',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          if (_isCreator) ...[
            Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                title: const Text('Group Members'),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _groupMembers.length,
              itemBuilder: (context, index) {
                final memberEmail = _groupMembers.keys.elementAt(index);
                bool isOwner = memberEmail == _groupOwnerEmail;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  elevation: 2,
                  child: ListTile(
                    title: Text(memberEmail),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: isOwner 
                          ? null 
                          : () => _removeMember(memberEmail), // Pass the email to remove
                      color: isOwner ? Colors.grey : null,
                    ),
                  ),
                );
              },
            ),
          ],
          // Spacer to push the button to the bottom
          const SizedBox(height: 16.0),  // Replace Expanded with SizedBox to control spacing
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),  // Add bottom padding
            child: ElevatedButton(
              onPressed: _updateGroup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}
