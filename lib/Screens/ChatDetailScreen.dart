import 'package:appdevproject/Widgets/MessageBubble.dart';
import 'package:appdevproject/services/Databaseservices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;

  ChatPage({required this.currentUserId, required this.otherUserId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  late Future<List<Message>> _messagesFuture;

  @override
  void initState() {
    super.initState();
    _messagesFuture = DatabaseServices.getUserMessages(
        widget.currentUserId, widget.otherUserId);
  }

  void _sendMessage() {
    String messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      Message message = Message(
        senderId: widget.currentUserId,
        receiverId: widget.otherUserId,
        messageText: messageText,
        timestamp: Timestamp.now(),
      );

      DatabaseServices.sendMessage(message);

      setState(() {
        // Refresh the message list
        _messagesFuture = DatabaseServices.getUserMessages(
            widget.currentUserId, widget.otherUserId);
      });

      // Clear the message input
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Message>>(
              future: _messagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                List<Message>? messages = snapshot.data;

                // Sort messages by timestamp in ascending order
                messages?.sort((a, b) => a.timestamp.compareTo(b.timestamp));

                return ListView.builder(
                  reverse:
                      false, // Set reverse to true to display the messages in descending order (latest at the bottom)
                  itemCount: messages?.length ?? 0,
                  itemBuilder: (context, index) {
                    Message message = messages![index];
                    bool isSentByCurrentUser =
                        message.senderId == widget.currentUserId;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: isSentByCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: isSentByCurrentUser
                                ? Color.fromRGBO(82, 184, 206, 100)
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message.messageText,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black,
                      hintText: 'Type your message...',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(82, 184, 206, 100),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromRGBO(82, 184, 206, 100)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    _sendMessage();
                  },
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
