import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gestion_de_ticket/couleur/couleur.dart';
import '../services/notification.dart';

class TicketsPage extends StatefulWidget {
  final String currentUserId;

  TicketsPage({required this.currentUserId});

  @override
  _TicketsPageState createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  String? _selectedCategory;
  String _status = 'En attente'; // Statut par défaut

  Future<List<String>> _getTrainerTokens() async {
    List<String> tokens = [];
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'formateur') // Récupérer les formateurs
        .get();
    for (var doc in snapshot.docs) {
      tokens.add(
          doc['token']); // Assurez-vous que ce champ existe dans votre document
    }
    return tokens;
  }

  void _addTicket() async {
    if (_titleController.text.isNotEmpty &&
        _detailsController.text.isNotEmpty &&
        _selectedCategory != null) {
      // Ajouter le ticket à Firestore et récupérer l'ID
      DocumentReference ticketRef =
          await FirebaseFirestore.instance.collection('tickets').add({
        'title': _titleController.text,
        'details': _detailsController.text,
        'category': _selectedCategory,
        'status': _status,
        'userId': widget.currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Réinitialiser les champs après ajout
      _titleController.clear();
      _detailsController.clear();
      _selectedCategory = null;

      // Envoyer une notification à tous les formateurs
      await LocalNotifications.sendNotificationsToTrainers(
        'Nouveau ticket créé',
        'Un nouveau ticket a été créé : ${_titleController.text}',
      );

      Navigator.of(context).pop(); // Fermer le dialogue
    }
  }

  void _cancelTicket(String ticketId) async {
    await FirebaseFirestore.instance
        .collection('tickets')
        .doc(ticketId)
        .update({
      'status': 'Annulé', // Mettre à jour le statut à "Annulé"
    });
  }

  void _showAddTicketDialog() async {
    final categorySnapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    final List<String> categories = categorySnapshot.docs
        .map((doc) => doc.data()['name'] as String)
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Ajouter un nouveau ticket'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(hintText: 'Titre du ticket'),
                    ),
                    TextField(
                      controller: _detailsController,
                      decoration:
                          InputDecoration(hintText: 'Détails du ticket'),
                    ),
                    DropdownButton(
                      hint: Text('Sélectionnez une catégorie'),
                      value: _selectedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      items: categories.map((String category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Réinitialiser les valeurs à l'état initial lorsque le bouton "Annuler" est cliqué
                    setState(() {
                      _titleController.clear();
                      _detailsController.clear();
                      _selectedCategory = null;
                    });
                    Navigator.of(context).pop(); // Fermer le dialogue
                  },
                  child: Text('Annuler'),
                ),
                TextButton(
                  onPressed: _addTicket,
                  child: Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'En cours':
        return Icons.hourglass_empty;
      case 'En attente':
        return Icons.access_time;
      case 'Résolu':
        return Icons.check_circle;
      case 'Annulé':
        return Icons.cancel; // Icône pour l'annulation
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'En cours':
        return Colors.orange;
      case 'En attente':
        return Colors.blue;
      case 'Résolu':
        return Colors.green;
      case 'Annulé':
        return Colors.red; // Couleur pour l'annulation
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Tickets',
            style: TextStyle(
              color: Couleurs.premierCouleur,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Couleurs.premierCouleur,
              size: 30,
            ),
            onPressed: _showAddTicketDialog,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .where('userId', isEqualTo: widget.currentUserId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aucun ticket trouvé.'));
          }

          final tickets = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final ticketId = doc.id; // Récupérer l'ID du ticket

            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              child: ListTile(
                contentPadding: EdgeInsets.all(4),
                leading: Icon(
                  _getStatusIcon(data['status']),
                  color: _getStatusColor(data['status']),
                ),
                title: Text(
                  data['title'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('Statut: ${data['status']}'),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Catégorie: ${data['category']}'),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      data['details'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Couleurs.premierCouleur, width: 3),
                ),
                trailing: TextButton(
                  onPressed: () {
                    _cancelTicket(ticketId); // Changer le statut en "Annulé"
                  },
                  child: Text(
                    'Annuler',
                    style: TextStyle(
                      color: Colors.red, // Couleur du texte du bouton
                      fontWeight:
                          FontWeight.bold, // Pour rendre le texte en gras
                    ),
                  ),
                ),
              ),
            );
          }).toList();

          return ListView(children: tickets);
        },
      ),
    );
  }
}
