import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String currentUserId;
  final String recipientId;
  final String recipientName; // Ajouter le nom et prénom

  ChatPage({
    required this.conversationId,
    required this.currentUserId,
    required this.recipientId,
    required this.recipientName, // Accepter le nom et prénom
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  void _onSendPressed(types.PartialText message) async {
    if (message.text.isEmpty) {
      return;
    }

    final textMessage = types.TextMessage(
      author: types.User(id: widget.currentUserId),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message.text,
    );

    await FirebaseFirestore.instance.collection('messages').add({
      'conversationId': widget.conversationId,
      'authorId': textMessage.author.id,
      'text': textMessage.text,
      'createdAt': textMessage.createdAt,
    });

    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationId)
        .update({
      'lastMessage': {
        'text': message.text,
        'createdAt': textMessage.createdAt,
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Chat with ${widget.recipientName}'), // Afficher le nom et prénom
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .where('conversationId', isEqualTo: widget.conversationId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final messages = snapshot.data?.docs
                  .map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (data['authorId'] != null &&
                        data['text'] != null &&
                        data['createdAt'] != null) {
                      return types.TextMessage(
                        author: types.User(id: data['authorId']),
                        createdAt: data['createdAt'],
                        id: doc.id,
                        text: data['text'],
                      );
                    }
                    return null;
                  })
                  .where((msg) => msg != null)
                  .cast<types.TextMessage>()
                  .toList() ??
              [];

          return Chat(
            messages: messages,
            onSendPressed: _onSendPressed,
            user: types.User(id: widget.currentUserId),
          );
        },
      ),
    );
  }
}
