import 'package:flutter/material.dart';
import 'package:msgapp_flutter/components/group_tile.dart';
import 'package:msgapp_flutter/components/my_searchbar.dart';
import 'package:msgapp_flutter/models/group.dart';
import 'package:msgapp_flutter/screens/create_group.dart';
import 'package:msgapp_flutter/screens/edit_group_page.dart';
import 'package:msgapp_flutter/screens/group_chat_page.dart';
import 'package:msgapp_flutter/screens/home_page.dart';
import 'package:msgapp_flutter/screens/profile_page.dart';
import 'package:msgapp_flutter/screens/settings_page.dart';
import 'package:msgapp_flutter/services/auth/auth_service.dart';
import 'package:msgapp_flutter/services/chat/group_chat_service.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final GroupChatService _groupChatService = GroupChatService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  List<Group> _allGroups = [];
  List<Group> _filteredGroups = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadGroups();
    _searchController.addListener(_filterGroups);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadGroups() {
    final currentUser = _authService.getCurrentUser();
    _groupChatService.getUserGroups(currentUser!.uid).listen((groups) {
      setState(() {
        _allGroups = groups;
        _filteredGroups = groups;
      });
    });
  }

  void _filterGroups() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredGroups = _allGroups
          .where((group) => group.name?.toLowerCase().contains(query) ?? false)
          .toList();
    });
  }

  void _editGroup(String groupId) {
    // Navigate to the edit group screen or open a dialog for editing
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditGroupPage(groupId: groupId),
      ),
    );
  }

  void _deleteGroup(String groupId) {
    // Call the service to delete the group
    _groupChatService.deleteGroup(groupId).then((_) {
      setState(() {
        _loadGroups(); // Reload the group list after deletion
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group deleted successfully')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Groups'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        foregroundColor: Colors.grey,
        elevation: 0,
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  _showMenu(context);
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: MySearchBar(
              controller: _searchController,
              onChanged: (query) {
                _filterGroups();
              },
            ),
          ),
          Expanded(child: _buildGroupList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateGroupPage()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.group_add),
      ),
    );
  }

  Widget _buildGroupList() {
    if (_filteredGroups.isEmpty) {
      return const Center(child: Text("No groups available."));
    }

    return ListView(
      children: _filteredGroups
          .map((group) => GroupTile(
                text: group.name ?? "Unknown Group",
                groupId: group.id,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupChatPage(
                        groupId: group.id,
                        groupName: group.name ?? "Unknown Group",
                      ),
                    ),
                  );
                },
                onEdit: () => _editGroup(group.id),
                onDelete: () => _deleteGroup(group.id),
              ))
          .toList(),
    );
  }

  void _showMenu(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 80, 20, 0),
      items: [
        PopupMenuItem(
          value: 1,
          child: ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () {
              _authService.signOut();
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}
