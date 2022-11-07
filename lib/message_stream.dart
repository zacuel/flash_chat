import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'components/message_widget.dart';

class MessageStream extends StatelessWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final User currentUser;
  const MessageStream(
      {super.key,
      required this.firestore,
      required this.auth,
      required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('messages').snapshots(),
      builder: ((context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(
            backgroundColor: Colors.lightBlueAccent,
          ));
        } else {
          final messages = snapshot.data!.docs;
          List<MessageWidget> messageWidgets = [];
          for (var message in messages) {
            final messageData = message.data() as Map<String, dynamic>;
            final messageText = messageData['text'];
            final messageSender = messageData['sender'];
            final messageDate = messageData['date'];
            final messageWidget = MessageWidget(
              text: messageText,
              sender: messageSender,
              isMe: currentUser.email == messageSender,
              messageDate: messageDate,
            );
            messageWidgets.add(messageWidget);
          }
          messageWidgets.sort((a, b) {
            return b.messageDate.toDate().compareTo(a.messageDate.toDate());
          });

          return Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              child: ListView(
                reverse: true,
                children: messageWidgets,
              ),
            ),
          );
        }
      }),
    );
  }
}
