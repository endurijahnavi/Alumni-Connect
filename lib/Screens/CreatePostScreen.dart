import 'dart:io';
import 'package:appdevproject/Constants/Post.dart';
import 'package:appdevproject/Widgets/RoundedButton.dart';
import 'package:appdevproject/services/Databaseservices.dart';
import 'package:appdevproject/services/StorageService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatefulWidget {
  final String currentUserId;

  const CreatePostScreen({Key? key, required this.currentUserId})
      : super(key: key);
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  late String _postText;
  File? _pickedImage;
  bool _loading = false;

  handleImageFromGallery() async {
    try {
      ImagePicker imagePicker = ImagePicker();
      PickedFile imageFile = (await imagePicker.pickImage(
          source: ImageSource.gallery)) as PickedFile;
      if (imageFile != null) {
        setState(() {
          _pickedImage = imageFile as File;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(142, 170, 96, 254),
        centerTitle: true,
        title: Text(
          'Post',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 20),
            TextField(
              maxLength: 280,
              maxLines: 7,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  hintText: 'Enter your Post',
                  fillColor: Colors.grey,
                  hintStyle: TextStyle(color: Colors.white)),
              onChanged: (value) {
                _postText = value;
              },
            ),
            SizedBox(height: 10),
            _pickedImage == null
                ? SizedBox.shrink()
                : Column(
                    children: [
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                            color: Color.fromARGB(142, 170, 96, 254),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: FileImage(_pickedImage!),
                            )),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
            GestureDetector(
              onTap: handleImageFromGallery,
              child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(
                    color: Color.fromARGB(142, 170, 96, 254),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 50,
                  color: Color.fromARGB(142, 170, 96, 254),
                ),
              ),
            ),
            SizedBox(height: 20),
            RoundedButton(
              btnText: 'Post',
              onBtnPressed: () async {
                setState(() {
                  _loading = true;
                });
                if (_postText != null && _postText.isNotEmpty) {
                  String image;
                  if (_pickedImage == null) {
                    image = '';
                  } else {
                    image =
                        await StorageService.uploadPostPicture(_pickedImage!);
                  }
                  Post post = Post(
                    text: _postText,
                    image: image,
                    authorId: widget.currentUserId,
                    likes: 0,
                    reposts: 0,
                    timestamp: Timestamp.fromDate(
                      DateTime.now(),
                    ),
                  );
                  DatabaseServices.createPost(post);
                  Navigator.pop(context);
                }
                setState(() {
                  _loading = false;
                });
              },
            ),
            SizedBox(height: 20),
            _loading ? CircularProgressIndicator() : SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}
