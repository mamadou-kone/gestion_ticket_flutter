import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gestion_de_ticket/couleur/couleur.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final TextEditingController _categoryController = TextEditingController();

  void _addCategory() async {
    if (_categoryController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('categories').add({
        'name': _categoryController.text,
      });
      _categoryController.clear(); // Effacer le champ de texte après ajout
      Navigator.of(context).pop(); // Fermer le dialogue
    }
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter une nouvelle catégorie'),
          content: TextField(
            controller: _categoryController,
            decoration: InputDecoration(hintText: 'Nom categorie'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialogue
              },
              child: Text('Annuller',
                  style: TextStyle(color: Couleurs.premierCouleur)),
            ),
            TextButton(
              onPressed: _addCategory,
              child: Text('Ajouter',
                  style: TextStyle(color: Couleurs.premierCouleur)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data?.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(data['name']),
                );
              }).toList() ??
              [];

          return ListView(children: categories);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        child: Icon(Icons.add, color: Couleurs.premierCouleur),
      ),
    );
  }
}
