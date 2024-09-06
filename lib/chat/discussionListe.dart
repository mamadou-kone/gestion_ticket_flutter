import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'chat.dart';
import 'listeUserPourConversation.dart';

class ConversationsPage extends StatelessWidget {
  final String currentUserId;

  ConversationsPage({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversations'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UsersListPage(currentUserId: currentUserId),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .where('participants', arrayContains: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final conversations = snapshot.data?.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final participants = List<String>.from(data['participants']);
                final recipientId =
                    participants.firstWhere((id) => id != currentUserId);

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(recipientId)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return ListTile(
                        title: Text('Loading...'),
                      );
                    }

                    if (userSnapshot.hasError || !userSnapshot.hasData) {
                      return ListTile(
                        title: Text('Error loading user'),
                      );
                    }

                    final userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    final recipientName =
                        '${userData['name']} ${userData['surname']}';

                    return ListTile(
                      title: Text('Conversation with $recipientName'),
                      subtitle: Text(data['lastMessage']['text'] ?? ''),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              conversationId: doc.id,
                              currentUserId: currentUserId,
                              recipientId: recipientId,
                              recipientName:
                                  recipientName, // Passer le nom et prénom
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }).toList() ??
              [];

          return ListView(
            children: conversations,
          );
        },
      ),
    );
  }
}
