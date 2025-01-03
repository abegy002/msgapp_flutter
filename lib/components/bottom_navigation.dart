// import 'package:flutter/material.dart';
// import 'package:msgapp_flutter/screens/chat_page.dart';
// import 'package:msgapp_flutter/screens/create_group.dart';
// import 'package:msgapp_flutter/screens/group_page.dart';
// import 'package:msgapp_flutter/screens/home_page.dart';
// import 'package:msgapp_flutter/screens/profile_page.dart';
// import 'package:msgapp_flutter/screens/settings_page.dart';

// class BottomNavigation extends StatefulWidget {
//   const BottomNavigation({super.key});

//   @override
//   _BottomNavigationState createState() => _BottomNavigationState();
// }

// class _BottomNavigationState extends State<BottomNavigation> {
//   int _selectedIndex = 0; // Keeps track of the selected index

//   // List of pages that will be navigated to based on the selected index
//   final List<Widget> _pages = [
//     const HomePage(),
//     const GroupPage(),   // You can add any page you want to show here
//     ProfilePage(),
//     const SettingsPage(),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex], // Show the current page based on the selected index
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex, // Highlight the selected tab
//         onTap: _onItemTapped, // Update the selected index when a tab is tapped
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.group),
//             label: 'Groups',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: 'Settings',
//           ),
//         ],
//       ),
//     );
//   }
// }
