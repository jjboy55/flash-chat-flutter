import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';

final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
final String collectionName = 'messages';
final String collectionText = 'text';
final String collectionSender = 'sender';
late User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = '/forthRoute';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String typedMessage;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  final TextEditingController controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: (value) {
                        typedMessage = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.clear();
                      _fireStore.collection('messages').add(
                          {'text': typedMessage, 'sender': loggedInUser.email});
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  const MessagesStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore.collection(collectionName).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data?.docs.toList().reversed;
        List<MessageBubble> chatTexts = [];
        for (var message in messages!) {
          final messageData = message.data() as Map<String, dynamic>;
          final messageText = messageData[collectionText];
          final messageSender = messageData[collectionSender];

          final textWidget = MessageBubble(
            messageSender: messageSender,
            messageText: messageText,
            itsMe: messageSender == loggedInUser.email,
          );
          chatTexts.add(textWidget);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            children: chatTexts,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String? messageText;
  final String messageSender;
  final bool itsMe;
  const MessageBubble(
      {required this.messageSender,
      required this.messageText,
      required this.itsMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            itsMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            'from $messageSender',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(
            height: 5,
          ),
          Material(
            color: itsMe ? Colors.lightBlueAccent : Colors.white,
            borderRadius: itsMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12))
                : BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                '$messageText',
                textAlign: TextAlign.center,
                style: TextStyle(color: itsMe ? Colors.white : Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
