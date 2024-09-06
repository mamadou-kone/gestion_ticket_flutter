import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chat.dart';

class UsersListPage extends StatelessWidget {
  final String currentUserId;

  UsersListPage({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select User'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data?.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final userId = doc.id;

                if (userId == currentUserId) {
                  return Container(); // Ne pas afficher l'utilisateur actuel
                }

                return ListTile(
                  title: Text('${data['name']} ${data['surname']}'),
                  onTap: () async {
                    // Récupérer toutes les conversations où currentUserId est un participant
                    final userConversations = await FirebaseFirestore.instance
                        .collection('conversations')
                        .where('participants', arrayContains: currentUserId)
                        .get();

                    String conversationId =
                        ''; // Initialiser avec une valeur par défaut
                    bool conversationExists = false;

                    // Vérifier si une conversation existe déjà avec userId comme participant
                    for (var doc in userConversations.docs) {
                      final participants = doc['participants'] as List<dynamic>;
                      if (participants.contains(userId)) {
                        conversationId = doc
                            .id; // Récupérer l'ID de la conversation existante
                        conversationExists = true;
                        break;
                      }
                    }

                    if (!conversationExists) {
                      // Créer une nouvelle conversation
                      final newConversationRef = await FirebaseFirestore
                          .instance
                          .collection('conversations')
                          .add({
                        'participants': [currentUserId, userId],
                        'lastMessage': {'text': '', 'createdAt': null},
                      });
                      conversationId = newConversationRef
                          .id; // Utilisez l'ID de la nouvelle conversation
                    }

                    // Passer le nom et le prénom à ChatPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          conversationId:
                              conversationId, // Passer l'ID de conversation
                          currentUserId: currentUserId,
                          recipientId: userId,
                          recipientName:
                              '${data['name']} ${data['surname']}', // Passer le nom et prénom
                        ),
                      ),
                    );
                  },
                );
              }).toList() ??
              [];

          return ListView(
            children: users,
          );
        },
      ),
    );
  }
}
