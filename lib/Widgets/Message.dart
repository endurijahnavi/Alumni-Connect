import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String messageText;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.messageText,
    required this.timestamp,
  });

  // Add a method to convert from a DocumentSnapshot to a Message instance
  factory Message.fromDoc(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Message(
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      messageText: data['messageText'],
      timestamp: data['timestamp'],
    );
  }
}
