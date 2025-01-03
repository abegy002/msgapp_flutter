import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:msgapp_flutter/components/my_drawer.dart';
import 'package:msgapp_flutter/components/my_searchbar.dart';
import 'package:msgapp_flutter/components/user_tile.dart';
import 'package:msgapp_flutter/screens/add_user.dart';
import 'package:msgapp_flutter/screens/chat_page.dart';
import 'package:msgapp_flutter/screens/settings_page.dart';
import 'package:msgapp_flutter/services/auth/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  late Stream<QuerySnapshot> _friendsStream; // Stream to listen for friends updates

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterFriends);
    _loadFriends();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadFriends() {
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) return;

    // Listen to real-time updates from Firestore
    _friendsStream = FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser.uid)
        .collection("Friends")
        .snapshots();
  }

  void _filterFriends() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      // No need to manually filter, we will let Firestore handle it with snapshots.
    });
  }

  Widget _buildFriendList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _friendsStream, // Stream of friends data
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong.'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No friends found.'));
        }

        final friendsData = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'uid': doc.id,
            'email': data['email'],
            'displayName': data['displayName'],
          };
        }).toList();

        // Filter the friends if search query exists
        final filteredFriends = friendsData.where((friend) {
          final query = _searchController.text.toLowerCase();
          return friend['email'].toLowerCase().contains(query) ||
              friend['displayName'].toLowerCase().contains(query);
        }).toList();

        return ListView(
          children: filteredFriends.map<Widget>((friendData) {
            return _buildFriendListItem(friendData);
          }).toList(),
        );
      },
    );
  }

  Widget _buildFriendListItem(Map<String, dynamic> friendData) {
    return UserTile(
      text: friendData['displayName'],
      subtitle: friendData['email'],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverID: friendData['uid'],
              receiverEmail: friendData['email'],
            ),
          ),
        );
      },
    );
  }

  void _showMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 50, 0, 0),
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Friends'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        foregroundColor: Colors.grey,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMenu(context),
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          MySearchBar(
            controller: _searchController,
            onChanged: (query) => _filterFriends(),
          ),
          Expanded(child: _buildFriendList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddUserPage()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
