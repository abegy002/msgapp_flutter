import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMessage {
  final String senderID;
  final String senderEmail;
  final List receiverIDs;
  final String message;
  final Timestamp timestamp;

  GroupMessage({
    required this.senderID,
    required this.senderEmail,
    required this.receiverIDs,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverIDs': receiverIDs,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
