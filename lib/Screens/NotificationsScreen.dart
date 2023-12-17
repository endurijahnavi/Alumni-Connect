import 'package:appdevproject/Constants/Constants.dart';
import 'package:appdevproject/Constants/Usermodel.dart';
import 'package:appdevproject/Constants/activity.dart';
import 'package:appdevproject/services/Databaseservices.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  final String currentUserId;

  const NotificationsScreen({Key? key, required this.currentUserId})
      : super(key: key);
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Activity> _activities = [];

  setupActivities() async {
    List<Activity> activities =
        await DatabaseServices.getActivities(widget.currentUserId);
    if (mounted) {
      setState(() {
        _activities = activities;
      });
    }
  }

  buildActivity(Activity activity) {
    return FutureBuilder(
        future: usersRef.doc(activity.fromUserId).get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return SizedBox.shrink();
          } else {
            UserModel user = UserModel.fromDoc(snapshot.data);
            return Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundImage: user.profilePicture.isEmpty
                        ? AssetImage('assets/images/splashscreenpic.png')
                        : NetworkImage(user.profilePicture.toString())
                            as ImageProvider<Object>?,
                  ),
                  title: activity.follow == true
                      ? Text('${user.name} follows you')
                      : Text('${user.name} liked your post'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Divider(
                    color: Color.fromRGBO(82, 184, 206, 100),
                    thickness: 1,
                  ),
                )
              ],
            );
          }
        });
  }

  @override
  void initState() {
    super.initState();
    setupActivities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.5,
          title: Text(
            'Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => setupActivities(),
          child: ListView.builder(
              itemCount: _activities.length,
              itemBuilder: (BuildContext context, int index) {
                Activity activity = _activities[index];
                return buildActivity(activity);
              }),
        ));
  }
}
