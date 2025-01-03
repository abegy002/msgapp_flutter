import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:msgapp_flutter/components/chat_bubble.dart';
import 'package:msgapp_flutter/components/group_chat_bubble.dart';
import 'package:msgapp_flutter/components/my_textfield.dart';
import 'package:msgapp_flutter/components/user_textfield.dart';
import 'package:msgapp_flutter/services/auth/auth_service.dart';
import 'package:msgapp_flutter/services/chat/group_chat_service.dart';

class GroupChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  GroupChatPage({required this.groupId, required this.groupName, Key? key})
      : super(key: key);

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final GroupChatService _groupChatService = GroupChatService();
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();

  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });

    Future.delayed(
      const Duration(milliseconds: 500),
      () => scrollDown(),
    );
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

void sendMessage() async {
  if (_messageController.text.isNotEmpty) {
    await _groupChatService.sendMessage(
      widget.groupId,
      _messageController.text,
      // Send the current timestamp
      FieldValue.serverTimestamp(),
    );
    _messageController.clear();
    scrollDown();
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey, Color.fromARGB(255, 177, 178, 181)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.black12,
              child: Text(
                widget.groupName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.groupName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('group_chat_rooms')
          .doc(widget.groupId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No messages yet. Be the first to send one!",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs
              .map((doc) => _buildMessageItem(doc))
              .toList(),
        );
      },
    );
  }

Widget _buildMessageItem(DocumentSnapshot doc) {
  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

  bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;

  // Format the timestamp
  Timestamp timestamp = data['timestamp'];
  DateTime messageTime = timestamp.toDate();

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    child: Row(
      mainAxisAlignment: isCurrentUser
          ? MainAxisAlignment.end // Align current user's message to the right
          : MainAxisAlignment.start, // Align other user's message to the left
      children: [
        isCurrentUser
            ? ChatBubble(
                message: data["message"],
                isCurrentUser: isCurrentUser,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ), timestamp: messageTime,
              )
            : GroupChatBubble(
                message: data["message"],
                isCurrentUser: isCurrentUser,
                userEmail: data["senderEmail"],
                backgroundColor: Colors.grey[200],
                textColor: Colors.black,
                timestamp: messageTime, // Pass the formatted timestamp
              ),
      ],
    ),
  );
}


  Widget _buildUserInput() {
  // Determine the current brightness mode
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Column(
    children: [
      // A Row for both text input and the send button
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 1.0),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.grey[800] // Match the dark mode message background
              : Colors.white, // White in light mode
          borderRadius: BorderRadius.circular(50), // Rounded corners
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                // Add functionality for adding attachments (e.g., images, documents)
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.attach_file, // Attachment icon
                  color: Colors.grey,
                ),
              ),
            ),
            // Reduced size for the UserTextfield
            Expanded(
              flex: 4,  // This controls the width of the textfield
              child: UserTextfield(
                controller: _messageController,
                focusNode: myFocusNode,
                hintText: "Type a message...",
                obscureText: false,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.grey.shade800, // Adjust text color
                ),
              ),
            ),
            // Send button
            GestureDetector(
              onTap: sendMessage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.green // Match the dark mode message background
                      : Colors.green, // Green in light mode
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send,
                  color: isDarkMode ? Colors.white : Colors.white, // Adjust icon color
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}}
