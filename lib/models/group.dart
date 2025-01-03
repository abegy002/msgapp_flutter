import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String owner; // New field for the group owner
  final List<String> members;
  final bool isGroup;

  Group({
    required this.id,
    required this.name,
    required this.owner,
    required this.members,
    required this.isGroup
  });

  factory Group.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Group(
      id: doc.id,
      name: data['name'],
      owner: data['owner'],
      members: List<String>.from(data['members']),
      isGroup: data['isGroup'],
    );
  }
}