import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:msgapp_flutter/components/chat_bubble.dart';
import 'package:msgapp_flutter/components/group_chat_bubble.dart';
import 'package:msgapp_flutter/components/my_textfield.dart';
import 'package:msgapp_flutter/components/user_textfield.dart';
import 'package:msgapp_flutter/services/auth/auth_service.dart';
import 'package:msgapp_flutter/services/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverID;
  final String receiverEmail;

  const ChatPage({
    super.key,
    required this.receiverID,
    required this.receiverEmail,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  final FocusNode myFocusNode = FocusNode();

  bool _isLoading = true;
  String _receiverFirstName = '';
  String _receiverLastName = '';

  @override
  void initState() {
    super.initState();
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 500), scrollDown);
      }
    });
    _loadReceiverProfile();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  Future<void> _loadReceiverProfile() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('Users').doc(widget.receiverID).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        setState(() {
          _receiverFirstName = data['firstName'] ?? '';
          _receiverLastName = data['lastName'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error if needed
    }
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.receiverID,
        _messageController.text,
        FieldValue.serverTimestamp(), // Adding timestamp to the message
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.light
                  ? [Colors.white, Color.fromARGB(255, 177, 178, 181)] // Light mode gradient
                  : [Colors.black, Color.fromARGB(255, 177, 178, 181)], // Dark mode gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        title: _isLoading
            ? const CircularProgressIndicator() // Loading state while fetching profile
            : Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black12,
                    child: Text(
                      _receiverFirstName.isNotEmpty
                          ? _receiverFirstName[0].toUpperCase()
                          : widget.receiverEmail[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      _receiverFirstName.isNotEmpty && _receiverLastName.isNotEmpty
                          ? '$_receiverFirstName $_receiverLastName'
                          : widget.receiverEmail,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
                      maxLines: 1, // Ensure text stays on one line
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
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderID),
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
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;

    // Get the timestamp from the document (it may be a Firebase Timestamp object)
    Timestamp timestamp = data['timestamp'];
    DateTime messageTime = timestamp.toDate(); // Convert to DateTime

    return Row(
      mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
          child: isCurrentUser ? ChatBubble(
                  message: data["message"],
                  isCurrentUser: true,
                  timestamp: messageTime, // Pass the timestamp here
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ) :
                ChatBubble(
                  message: data["message"],
                  isCurrentUser: false,
                  timestamp: messageTime, // Pass the timestamp here
                  backgroundColor: Colors.grey,
                  textColor: Colors.black,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                )
        ),
      ],
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
}


}
