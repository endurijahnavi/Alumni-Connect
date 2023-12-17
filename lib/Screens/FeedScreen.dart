import 'package:appdevproject/Screens/ChatScreen.dart';
import 'package:appdevproject/Screens/HomeScreen.dart';
import 'package:appdevproject/Screens/NotificationsScreen.dart';
import 'package:appdevproject/Screens/ProfileScreen.dart';
import 'package:appdevproject/Screens/SearchScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class FeedScreen extends StatefulWidget {
  final String currentUserId;

  const FeedScreen({Key? key, required this.currentUserId}) : super(key: key);
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _selectedTab = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        HomeScreen(
          currentUserId: widget.currentUserId,
        ),
        SearchScreen(
          currentUserId: widget.currentUserId,
        ),
        ChatScreen(
          currentUserId: widget.currentUserId,
        ),
        NotificationsScreen(
          currentUserId: widget.currentUserId,
        ),
        ProfileScreen(
          currentUserId: widget.currentUserId,
          visitedUserId: widget.currentUserId,
        ),
      ].elementAt(_selectedTab),
      // bottomNavigationBar: CupertinoTabBar(
      //   onTap: (index) {
      //     setState(() {
      //       _selectedTab = index;
      //     });
      //   },
      //   activeColor: Color.fromARGB(142, 170, 96, 254),
      //   currentIndex: _selectedTab,
      //   items: [
      //     BottomNavigationBarItem(icon: Icon(Icons.home)),
      //     BottomNavigationBarItem(icon: Icon(Icons.search)),
      //     BottomNavigationBarItem(icon: Icon(Icons.chat_bubble)),
      //     BottomNavigationBarItem(icon: Icon(Icons.notifications)),
      //     BottomNavigationBarItem(icon: Icon(Icons.person)),
      //   ],
      // ),
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.black,
        backgroundColor: Color.fromRGBO(82, 184, 206, 100),
        buttonBackgroundColor: Colors.black,
        onTap: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        items: <Widget>[
          Icon(
            Icons.home_rounded,
            size: 20,
            color: Color.fromRGBO(82, 184, 206, 100),
          ),
          Icon(
            Icons.search,
            size: 20,
            color: Color.fromRGBO(82, 184, 206, 100),
          ),
          Icon(
            Icons.chat_bubble,
            size: 20,
            color: Color.fromRGBO(82, 184, 206, 100),
          ),
          Icon(
            Icons.notifications,
            size: 20,
            color: Color.fromRGBO(82, 184, 206, 100),
          ),
          Icon(
            Icons.person,
            size: 20,
            color: Color.fromRGBO(82, 184, 206, 100),
          )
        ],
      ),
    );
  }
}
