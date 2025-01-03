import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:msgapp_flutter/models/group.dart';
import 'package:msgapp_flutter/models/group_message.dart';

class GroupChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to send a message to a group chat
  Future<void> sendMessage(String groupId, String message, FieldValue serverTimestamp) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // Fetch group members
    DocumentSnapshot groupSnapshot = await _firestore.collection('groups').doc(groupId).get();
    List<dynamic> groupMembers = groupSnapshot['members'];

    // Ensure the current user is part of the group
    if (!groupMembers.contains(currentUserId)) {
      throw Exception("User is not a member of this group");
    }

    GroupMessage newMessage = GroupMessage(
      senderID: currentUserId,
      senderEmail: currentUserEmail,
      receiverIDs: groupMembers,
      message: message,
      timestamp: timestamp,
    );

    // Add the message to the Firestore collection
    await _firestore
        .collection('group_chat_rooms')
        .doc(groupId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  // Create a new group
  Future<void> createGroup(String groupName, List<String> userIds) async {
    final String ownerId = _auth.currentUser!.uid;

    // Create group document
    final groupDoc = _firestore.collection('groups').doc();

    await groupDoc.set({
      'name': groupName,
      'isGroup': true,
      'owner': ownerId,
      'members': [ownerId, ...userIds],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get groups that the user is a member of
  Stream<List<Group>> getUserGroups(String userId) {
    return _firestore
        .collection('groups')
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Group.fromFirestore(doc)).toList());
  }

  // Get a stream of all groups
  // Stream<List<Map<String, dynamic>>> getGroupStream() {
  //   return _firestore.collection('groups').snapshots().map((snapshot) {
  //     return snapshot.docs.map((doc) {
  //       return {
  //         'groupID': doc.id,
  //         ...doc.data() as Map<String, dynamic>,
  //       };
  //     }).toList();
  //   });
  // }

  // Modifier un groupe (par exemple, modifier le nom du groupe)
  Future<void> updateGroup(String groupId, String newGroupName) async {
    try {
      await _firestore.collection('groups').doc(groupId).update({
        'name': newGroupName,
        'updated_at': Timestamp.now(),
      });
      print('Group updated');
    } catch (e) {
      print("Error updating group: $e");
    }
  }

  // Supprimer un groupe
  Future<void> deleteGroup(String groupId) async {
    try {
      await _firestore.collection('groups').doc(groupId).delete();
      print('Group deleted');
    } catch (e) {
      print("Error deleting group: $e");
    }
  }

// Supprimer un membre d'un groupe
Future<void> removeMemberFromGroup(String groupId, String userId) async {
  try {
    // Fetch the group data to check if the current user is the group owner
    DocumentSnapshot groupSnapshot = await _firestore.collection('groups').doc(groupId).get();

    if (!groupSnapshot.exists) {
      throw Exception("Group does not exist.");
    }

    // Check if the current user is the group owner
    String groupOwnerId = groupSnapshot['owner'];
    final String currentUserId = _auth.currentUser!.uid;

    if (currentUserId != groupOwnerId) {
      throw Exception("Only the group creator can remove members.");
    }

    // Remove the member from the 'members' array in Firestore
    await _firestore.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([userId]), // Remove the member from the members array
    });

    // Optionally, you can print success or update the UI (or notify the user)
    print('User removed from the group');
  } catch (e) {
    print("Error removing member from group: $e");
    // Optionally, show a UI error
    throw Exception("Failed to remove member: $e");
  }
}





  // Get a group by its ID
  Future<Group> getGroupById(String groupId) async {
    try {
      DocumentSnapshot groupSnapshot = await _firestore.collection('groups').doc(groupId).get();
      return Group.fromFirestore(groupSnapshot);
    } catch (e) {
      throw Exception("Error fetching group: $e");
    }
  }

  // Get the current user's ID
  Future<String> getCurrentUserId() async {
    try {
      return _auth.currentUser!.uid;
    } catch (e) {
      throw Exception("Error fetching user ID: $e");
    }
  }
}
