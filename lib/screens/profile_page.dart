import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:msgapp_flutter/screens/settings_page.dart'; // Import Settings page
import 'package:msgapp_flutter/services/auth/auth_service.dart'; // Import the AuthService

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  late User _user;
  bool _isLoading = true;

  String _email = '';
  String _firstName = '';
  String _lastName = '';
  String _phoneNumber = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

Future<void> _loadUserProfile() async {
  try {
    final user = _authService.getCurrentUser();
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        setState(() {
          _user = user;
          _email = data['email'] ?? user.email ?? '';
          _firstName = data['firstName'] ?? '';
          _lastName = data['lastName'] ?? '';
          _phoneNumber = data['phoneNumber'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog("User profile not found.");
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog("User not authenticated.");
    }
  } catch (e) {
    setState(() {
      _isLoading = false;
    });
    _showErrorDialog("An error occurred: $e");
  }
}


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      Navigator.pop(context); // Navigate to login page after logout
    } catch (e) {
      _showErrorDialog("Failed to logout: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: theme.colorScheme.tertiary,
        foregroundColor: Colors.grey,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile image at the top
                    CircleAvatar(
                      radius: 50,
                    ),
                    const SizedBox(height: 20),

                    // Profile Information Card
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileInfoRow("First Name", _firstName),
                            _buildProfileInfoRow("Last Name", _lastName),
                            _buildProfileInfoRow("Email", _email),
                            _buildProfileInfoRow("Phone Number", _phoneNumber),
                          ],
                        ),
                      ),
                    ),

                    // Settings Card
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: const Text("Settings"),
                        leading: const Icon(Icons.settings),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingsPage()),
                          );
                        },
                      ),
                    ),

                    // Logout Card
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: const Text("Logout"),
                        leading: const Icon(Icons.logout),
                        onTap: _logout,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Edit Profile Button
                    ElevatedButton(
                      onPressed: _editProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text(
                        "Edit Profile",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

Future<void> _editProfile() async {
  final firstNameController = TextEditingController(text: _firstName);
  final lastNameController = TextEditingController(text: _lastName);
  final phoneNumberController = TextEditingController(text: _phoneNumber);

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Edit Profile"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: firstNameController,
            decoration: const InputDecoration(labelText: 'First Name'),
          ),
          TextField(
            controller: lastNameController,
            decoration: const InputDecoration(labelText: 'Last Name'),
          ),
          TextField(
            controller: phoneNumberController,
            decoration: const InputDecoration(labelText: 'Phone Number'),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            try {
              // Update the profile in Firestore
              await _authService.editProfile(
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                phoneNumber: phoneNumberController.text,
              );

              // Update local state to reflect changes
              setState(() {
                _firstName = firstNameController.text;
                _lastName = lastNameController.text;
                _phoneNumber = phoneNumberController.text;
              });

              Navigator.pop(context);
            } catch (e) {
              _showErrorDialog("Failed to update profile: $e");
            }
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}

}
