import 'package:appdevproject/Constants/Usermodel.dart';
import 'package:appdevproject/Constants/Post.dart';
import 'package:appdevproject/services/Databaseservices.dart';
import 'package:flutter/material.dart';

class PostContainer extends StatefulWidget {
  final Post post;
  final UserModel author;
  final String currentUserId;

  const PostContainer({
    Key? key, // Make the key parameter optional
    required this.post,
    required this.author,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _PostContainerState createState() => _PostContainerState();
}

class _PostContainerState extends State<PostContainer> {
  int _likesCount = 0;
  bool _isLiked = false;

  initPostLikes() async {
    bool isLiked =
        await DatabaseServices.isLikePost(widget.currentUserId, widget.post);
    if (mounted) {
      setState(() {
        _isLiked = isLiked;
      });
    }
  }

  likePost() {
    if (_isLiked) {
      DatabaseServices.unlikePost(widget.currentUserId, widget.post);
      setState(() {
        _isLiked = false;
        _likesCount--;
      });
    } else {
      DatabaseServices.likePost(widget.currentUserId, widget.post);
      setState(() {
        _isLiked = true;
        _likesCount++;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _likesCount = widget.post.likes;
    initPostLikes();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: widget.author.profilePicture.isEmpty
                    ? const AssetImage('assets/images/splashscreenpic.png')
                    : NetworkImage(widget.author.profilePicture.toString())
                        as ImageProvider<Object>?,
              ),
              SizedBox(width: 10),
              Text(
                widget.author.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            widget.post.text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          widget.post.image.isEmpty
              ? SizedBox.shrink()
              : Column(
                  children: [
                    SizedBox(height: 15),
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(82, 184, 206, 100),
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(widget.post.image),
                          )),
                    )
                  ],
                ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked
                          ? Color.fromRGBO(82, 184, 206, 100)
                          : Colors.white,
                    ),
                    onPressed: likePost,
                  ),
                  Text(
                    _likesCount.toString() + ' Likes',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              Text(
                widget.post.timestamp.toDate().toString().substring(0, 19),
                style: TextStyle(color: Colors.grey),
              )
            ],
          ),
          SizedBox(height: 10),
          Divider(
            thickness: 2,
          )
        ],
      ),
    );
  }
}
