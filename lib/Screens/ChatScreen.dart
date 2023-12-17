import 'package:appdevproject/Constants/Constants.dart';
import 'package:appdevproject/Constants/Usermodel.dart';
import 'package:appdevproject/Screens/ChatDetailScreen.dart';
import 'package:appdevproject/services/Databaseservices.dart';
import 'package:flutter/material.dart';
// ... (your imports)

class ChatScreen extends StatefulWidget {
  final String currentUserId;

  const ChatScreen({
    Key? key,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<UserModel> _chatUsers = [];

  setupChatUsers() async {
    List<String> followingUsers =
        await DatabaseServices.getFollowingUsers(widget.currentUserId);
    List<String> followersUsers =
        await DatabaseServices.getFollowersUsers(widget.currentUserId);
    List<String> mutualUsers = followingUsers
        .where((userId) => followersUsers.contains(userId))
        .toList();
    List<UserModel> chatUsersDetails =
        await DatabaseServices.getUsersDetails(mutualUsers);

    if (mounted) {
      setState(() {
        _chatUsers = chatUsersDetails;
      });
    }
  }

  buildChatUser(UserModel user) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey, width: 0.5),
        ),
        leading: CircleAvatar(
          radius: 20,
          backgroundImage: user.profilePicture.isEmpty
              ? AssetImage('assets/images/splashscreenpic.png')
              : NetworkImage(user.profilePicture) as ImageProvider<Object>?,
        ),
        title: Text(user.name),
        subtitle: Text(user.bio),
        trailing: Icon(Icons.chat_bubble_rounded),
        onTap: () {
          // Navigate to the chat screen with the selected user
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                currentUserId: widget.currentUserId,
                otherUserId: user.id,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    setupChatUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.5,
        title: Text(
          'Chat',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => setupChatUsers(),
        child: ListView.builder(
          itemCount: _chatUsers.length,
          itemBuilder: (BuildContext context, int index) {
            UserModel user = _chatUsers[index];
            return buildChatUser(user);
          },
        ),
      ),
    );
  }
}
