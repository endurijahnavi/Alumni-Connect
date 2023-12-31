import 'package:appdevproject/Constants/Constants.dart';
import 'package:appdevproject/Constants/Usermodel.dart';
import 'package:appdevproject/Constants/activity.dart';
import 'package:appdevproject/Constants/Post.dart';
import 'package:appdevproject/Widgets/MessageBubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  static Future<int> followersNum(String userId) async {
    QuerySnapshot followersSnapshot =
        await followersRef.doc(userId).collection('Followers').get();
    return followersSnapshot.docs.length;
  }

  static Future<int> followingNum(String userId) async {
    QuerySnapshot followingSnapshot =
        await followingRef.doc(userId).collection('Following').get();
    return followingSnapshot.docs.length;
  }

  static void updateUserData(UserModel user) {
    usersRef.doc(user.id).update({
      'name': user.name,
      'bio': user.bio,
      'profilePicture': user.profilePicture,
      'coverImage': user.coverImage,
    });
  }

  static Future<QuerySnapshot> searchUsers(String name) async {
    Future<QuerySnapshot> users = usersRef
        .where('name', isGreaterThanOrEqualTo: name)
        .where('name', isLessThan: name + 'z')
        .get();

    return users;
  }

  static void followUser(String currentUserId, String visitedUserId) {
    followingRef
        .doc(currentUserId)
        .collection('Following')
        .doc(visitedUserId)
        .set({});
    followersRef
        .doc(visitedUserId)
        .collection('Followers')
        .doc(currentUserId)
        .set({});

    addActivity(currentUserId, null, true, visitedUserId);
  }

  static void unFollowUser(String currentUserId, String visitedUserId) {
    followingRef
        .doc(currentUserId)
        .collection('Following')
        .doc(visitedUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    followersRef
        .doc(visitedUserId)
        .collection('Followers')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  static Future<bool> isFollowingUser(
      String currentUserId, String visitedUserId) async {
    DocumentSnapshot followingDoc = await followersRef
        .doc(visitedUserId)
        .collection('Followers')
        .doc(currentUserId)
        .get();
    return followingDoc.exists;
  }

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static void sendMessage(Message message) {
    // Save the message to the sender's collection
    _firestore
        .collection('messages')
        .doc(message.senderId)
        .collection('userMessages')
        .doc(message.receiverId)
        .collection('chat')
        .add({
      'messageText': message.messageText,
      'timestamp': message.timestamp,
      'senderId': message.senderId,
      'receiverId': message.receiverId,
    }); // Save the message to the receiver's collection
    _firestore
        .collection('messages')
        .doc(message.receiverId)
        .collection('userMessages')
        .doc(message.senderId)
        .collection('chat')
        .add({
      'messageText': message.messageText,
      'timestamp': message.timestamp,
      'senderId': message.senderId,
      'receiverId': message.receiverId,
    });
  }

  static Future<List<Message>> getUserMessages(
      String userId, String otherUserId) async {
    QuerySnapshot userMessagesSnap = await _firestore
        .collection('messages')
        .doc(userId)
        .collection('userMessages')
        .doc(otherUserId)
        .collection('chat')
        .orderBy('timestamp', descending: true)
        .get();

    List<Message> userMessages =
        userMessagesSnap.docs.map((doc) => Message.fromDoc(doc)).toList();

    return userMessages;
  }

  static Future<void> createPost(Post post) async {
    postsRef.doc(post.authorId).set({'postTime': post.timestamp});
    postsRef.doc(post.authorId).collection('userPosts').add({
      'text': post.text,
      'image': post.image,
      "authorId": post.authorId,
      "timestamp": post.timestamp,
      'likes': post.likes,
      'reposts': post.reposts,
    }).then((doc) async {
      QuerySnapshot followerSnapshot =
          await followersRef.doc(post.authorId).collection('Followers').get();

      for (var docSnapshot in followerSnapshot.docs) {
        feedRefs.doc(docSnapshot.id).collection('userFeed').doc(doc.id).set({
          'text': post.text,
          'image': post.image,
          "authorId": post.authorId,
          "timestamp": post.timestamp,
          'likes': post.likes,
          'reposts': post.reposts,
        });
      }
    });
  }

  static Future<List> getUserPosts(String userId) async {
    QuerySnapshot userPostsSnap = await postsRef
        .doc(userId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    List<Post> userPosts =
        userPostsSnap.docs.map((doc) => Post.fromDoc(doc)).toList();

    return userPosts;
  }

  static Future<List> getHomePosts(String currentUserId) async {
    QuerySnapshot homePosts = await feedRefs
        .doc(currentUserId)
        .collection('userFeed')
        .orderBy('timestamp', descending: true)
        .get();

    List<Post> followingPosts =
        homePosts.docs.map((doc) => Post.fromDoc(doc)).toList();
    return followingPosts;
  }

  static Future<List<String>> getFollowingUsers(String userId) async {
    QuerySnapshot followingSnapshot =
        await followingRef.doc(userId).collection('Following').get();
    List<String> followingUsers =
        followingSnapshot.docs.map((doc) => doc.id).toList();
    return followingUsers;
  }

  static Future<List<String>> getFollowersUsers(String userId) async {
    QuerySnapshot followersSnapshot =
        await followersRef.doc(userId).collection('Followers').get();
    List<String> followersUsers =
        followersSnapshot.docs.map((doc) => doc.id).toList();
    return followersUsers;
  }

  static Future<List<UserModel>> getUsersDetails(List<String> userIds) async {
    List<UserModel> usersDetails = [];

    for (String userId in userIds) {
      DocumentSnapshot userSnapshot = await usersRef.doc(userId).get();
      if (userSnapshot.exists) {
        UserModel user = UserModel.fromDoc(userSnapshot);
        usersDetails.add(user);
      }
    }

    return usersDetails;
  }

  static void likePost(String currentUserId, Post post) {
    DocumentReference postDocProfile =
        postsRef.doc(post.authorId).collection('userPosts').doc(post.id);
    postDocProfile.get().then((doc) {
      int? likes = (doc.data() as Map<String, dynamic>)?['likes'];
      postDocProfile.update({'likes': likes! + 1});
    });

    DocumentReference postDocFeed =
        feedRefs.doc(currentUserId).collection('userFeed').doc(post.id);
    postDocFeed.get().then((doc) {
      if (doc.exists) {
        int? likes = (doc.data() as Map<String, dynamic>)?['likes'];
        postDocFeed.update({'likes': likes! + 1});
      }
    });

    likesRef.doc(post.id).collection('postLikes').doc(currentUserId).set({});

    addActivity(currentUserId, post, false, null);
  }

  static void unlikePost(String currentUserId, Post post) {
    DocumentReference postDocProfile =
        postsRef.doc(post.authorId).collection('userPosts').doc(post.id);
    postDocProfile.get().then((doc) {
      int? likes = (doc.data() as Map<String, dynamic>)?['likes'];
      postDocProfile.update({'likes': likes! - 1});
    });

    DocumentReference postDocFeed =
        feedRefs.doc(currentUserId).collection('userFeed').doc(post.id);
    postDocFeed.get().then((doc) {
      if (doc.exists) {
        int? likes = (doc.data() as Map<String, dynamic>)?['likes'];
        postDocFeed.update({'likes': likes! - 1});
      }
    });

    likesRef
        .doc(post.id)
        .collection('postLikes')
        .doc(currentUserId)
        .get()
        .then((doc) => doc.reference.delete());
  }

  static Future<bool> isLikePost(String currentUserId, Post post) async {
    DocumentSnapshot userDoc = await likesRef
        .doc(post.id)
        .collection('postLikes')
        .doc(currentUserId)
        .get();

    return userDoc.exists;
  }

  static Future<List<Activity>> getActivities(String userId) async {
    QuerySnapshot userActivitiesSnapshot = await activitiesRef
        .doc(userId)
        .collection('userActivities')
        .orderBy('timestamp', descending: true)
        .get();

    List<Activity> activities = userActivitiesSnapshot.docs
        .map((doc) => Activity.fromDoc(doc))
        .toList();

    return activities;
  }

  static void addActivity(
      String currentUserId, Post? post, bool follow, String? followedUserId) {
    if (follow) {
      if (followedUserId != null) {
        activitiesRef.doc(followedUserId).collection('userActivities').add({
          'fromUserId': currentUserId,
          'timestamp': Timestamp.fromDate(DateTime.now()),
          "follow": true,
        });
      } else {
        // Handle the case when followedUserId is null
      }
    } else {
      // like
      if (post != null && post.authorId != null) {
        activitiesRef.doc(post.authorId).collection('userActivities').add({
          'fromUserId': currentUserId,
          'timestamp': Timestamp.fromDate(DateTime.now()),
          "follow": false,
        });
      } else {
        // Handle the case when post or post.authorId is null
      }
    }
  }
}
