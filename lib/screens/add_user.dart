import 'package:flutter/material.dart';
import 'package:msgapp_flutter/components/adduser_tile.dart';
import 'package:msgapp_flutter/components/my_drawer.dart';
import 'package:msgapp_flutter/components/my_searchbar.dart';
import 'package:msgapp_flutter/components/user_tile.dart';
import 'package:msgapp_flutter/screens/chat_page.dart';
import 'package:msgapp_flutter/screens/settings_page.dart';
import 'package:msgapp_flutter/services/auth/auth_service.dart';
import 'package:msgapp_flutter/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  Set<String> _addedFriends = {}; // Track added friends

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadFriends();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    _chatService.getUserStream().listen((users) async {
      final currentUser = _authService.getCurrentUser();
      final currentUserEmail = currentUser?.email;

      List<Map<String, dynamic>> updatedUsers = [];
      for (var user in users) {
        if (user['email'] == currentUserEmail) continue;

        final doc = await FirebaseFirestore.instance
            .collection("Users")
            .doc(user['uid'])
            .get();

        if (doc.exists) {
          final data = doc.data() ?? {};
          String displayName = user['email'];

          if (data.containsKey('firstName') && data.containsKey('lastName')) {
            displayName = '${data['firstName']} ${data['lastName']}';
          }

          updatedUsers.add({
            'uid': user['uid'],
            'email': user['email'],
            'displayName': displayName,
          });
        }
      }

      setState(() {
        _allUsers = updatedUsers;
        _filteredUsers = _allUsers;
      });
    });
  }

  void _loadFriends() async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) return;

    final friendsSnapshot = await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser.uid)
        .collection("Friends")
        .get();

    setState(() {
      _addedFriends = friendsSnapshot.docs.map((doc) => doc.id).toSet();
    });
  }

  void _addOrRemoveFriend(
      String userId, String email, String displayName) async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) return;

    if (_addedFriends.contains(userId)) {
      // Remove friend
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser.uid)
          .collection("Friends")
          .doc(userId)
          .delete();

      setState(() {
        _addedFriends.remove(userId);
      });
    } else {
      // Add friend
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser.uid)
          .collection("Friends")
          .doc(userId)
          .set({
        'email': email,
        'displayName': displayName,
        'addedAt': Timestamp.now(),
      });

      setState(() {
        _addedFriends.add(userId);
      });
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers
          .where((user) =>
              user['email'].toLowerCase().contains(query) ||
              user['displayName'].toLowerCase().contains(query))
          .toList();
    });
  }

  Widget _buildUserList() {
    if (_filteredUsers.isEmpty) {
      return const Center(
        child: Text("No users found."),
      );
    }

    return ListView(
      children: _filteredUsers.map<Widget>((userData) {
        final isFriend = _addedFriends.contains(userData['uid']);
        return AddUserTile(
          text: userData['displayName'], // Use 'text' instead of 'title'
          subtitle: userData['email'], // Optionally pass subtitle
          leading: CircleAvatar(
            child: Text(userData['displayName'][0]),
          ),
          trailing: ElevatedButton(
            onPressed: () {
              _addOrRemoveFriend(
                  userData['uid'], userData['email'], userData['displayName']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isFriend ? Colors.red : Colors.green,
            ),
            child: Text(
              isFriend ? '-' : '+',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  receiverID: userData['uid'],
                  receiverEmail: userData['email'],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Add Friend'),
        backgroundColor: theme.colorScheme.tertiary,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Column(
        children: [
          MySearchBar(
            controller: _searchController,
            onChanged: (query) => _filterUsers(),
          ),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }
}
