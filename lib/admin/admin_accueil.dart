import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestion_de_ticket/couleur/couleur.dart'; // Import Font Awesome

class FormateurListPage extends StatefulWidget {
  @override
  _FormateurListPageState createState() => _FormateurListPageState();
}

class _FormateurListPageState extends State<FormateurListPage> {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Variables pour stocker les comptages
  int totalFormateurs = 0;
  int totalAdmins = 0;

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  // Méthode pour récupérer les comptages depuis Firestore
  Future<void> _fetchCounts() async {
    // Récupérer les documents qui ont le rôle "formateur"
    final formateursCountSnapshot =
        await usersCollection.where('role', isEqualTo: 'formateur').get();

    // Récupérer les documents qui ont le rôle "admin"
    final adminsCountSnapshot =
        await usersCollection.where('role', isEqualTo: 'admin').get();

    setState(() {
      totalFormateurs = formateursCountSnapshot.size;
      totalAdmins = adminsCountSnapshot.size;
    });
  }

  // Méthode pour afficher la boîte de dialogue de confirmation avant la suppression
  Future<void> _confirmDeleteFormateur(String id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // L'utilisateur doit appuyer sur un bouton pour fermer la boîte de dialogue
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Êtes-vous sûr de vouloir supprimer ce formateur ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
            ),
            TextButton(
              child: Text('Supprimer'),
              onPressed: () async {
                await _deleteFormateur(id);
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
            ),
          ],
        );
      },
    );
  }

  // Méthode pour supprimer un formateur
  Future<void> _deleteFormateur(String id) async {
    await usersCollection
        .doc(id)
        .delete(); // Utilisation de la collection "users"
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Formateur supprimé avec succès')),
    );
  }

  // Méthode pour afficher le formulaire de modification
  void _showEditForm(DocumentSnapshot formateur) {
    final TextEditingController nameController =
        TextEditingController(text: formateur['name']);
    final TextEditingController surnameController =
        TextEditingController(text: formateur['surname']);
    final TextEditingController emailController =
        TextEditingController(text: formateur['email']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier Formateur'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: surnameController,
                decoration: InputDecoration(labelText: 'Prénom'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Mise à jour des données du formateur
                await usersCollection.doc(formateur.id).update({
                  'name': nameController.text.trim(),
                  'surname': surnameController.text.trim(),
                  'email': emailController.text.trim(),
                });

                Navigator.of(context).pop(); // Fermer le formulaire
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Formateur modifié avec succès')),
                );
              },
              child: Text('Sauvegarder'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le formulaire
              },
              child: Text('Annuler'),
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
        title: Text('Liste des Formateurs'),
      ),
      body: Column(
        children: [
          // Afficher les comptages en haut de la liste
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      'Total Formateurs',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(totalFormateurs.toString()),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Total Administrateurs',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(totalAdmins.toString()),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Filtrer pour récupérer uniquement les formateurs
              stream: usersCollection
                  .where('role', isEqualTo: 'formateur')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Une erreur s\'est produite'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final formateurs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: formateurs.length,
                  itemBuilder: (context, index) {
                    final formateur = formateurs[index];

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: FaIcon(FontAwesomeIcons.userTie,
                            color: Couleurs.premierCouleur),
                        title: Text(
                            '${formateur['name']} ${formateur['surname']}'),
                        subtitle: Text(formateur['email']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: FaIcon(FontAwesomeIcons.edit,
                                  color: Colors.blue),
                              onPressed: () => _showEditForm(formateur),
                            ),
                            IconButton(
                              icon: FaIcon(FontAwesomeIcons.trashAlt,
                                  color: Couleurs.premierCouleur),
                              onPressed: () => _confirmDeleteFormateur(formateur
                                  .id), // Appel de la fonction de confirmation
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
