import 'package:appdevproject/Constants/Constants.dart';
import 'package:appdevproject/Constants/Usermodel.dart';
import 'package:appdevproject/Constants/Post.dart';
import 'package:appdevproject/Screens/CreatePostScreen.dart';
import 'package:appdevproject/Widgets/Container.dart';
import 'package:appdevproject/services/Databaseservices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;

  const HomeScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List _followingPosts = [];
  bool _loading = false;

  buildPosts(Post post, UserModel author) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: PostContainer(
        post: post,
        author: author,
        currentUserId: widget.currentUserId,
      ),
    );
  }

  Future<List<Widget>> showFollowingPosts(String currentUserId) async {
    List<Widget> followingPostsList = [];

    for (Post post in _followingPosts) {
      DocumentSnapshot snapshot = await usersRef.doc(post.authorId).get();
      if (snapshot.exists) {
        UserModel author = UserModel.fromDoc(snapshot);
        followingPostsList.add(buildPosts(post, author));
      }
    }

    return followingPostsList;
  }

  setupFollowingPosts() async {
    setState(() {
      _loading = true;
    });

    try {
      List followingPosts =
          await DatabaseServices.getHomePosts(widget.currentUserId);

      print('Following Posts: $followingPosts');

      if (mounted) {
        setState(() {
          _followingPosts = followingPosts;
          _loading = false;
        });
      }
    } catch (e) {
      print('Error fetching following posts: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setupFollowingPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePostScreen(
                currentUserId: widget.currentUserId,
              ),
            ),
          );
        },
      ),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(142, 170, 96, 254),
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'Alumni Connect',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => await setupFollowingPosts(),
        child: ListView(
          physics: BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          children: [
            SizedBox.shrink(),
            SizedBox(height: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 5),
                _followingPosts.isEmpty && !_loading
                    ? Column(
                        children: [
                          SizedBox(height: 5),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25),
                            child: Text(
                              'There are No New Posts',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      )
                    : FutureBuilder<List<Widget>>(
                        future: showFollowingPosts(widget.currentUserId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  Color.fromARGB(142, 170, 96, 254),
                                ),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Column(
                              children: snapshot.data ?? [],
                            );
                          }
                        },
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
