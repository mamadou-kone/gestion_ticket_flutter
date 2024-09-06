import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestion_de_ticket/couleur/couleur.dart'; // Import Font Awesome

class ApprenantListPage extends StatefulWidget {
  @override
  _ApprenantListPageState createState() => _ApprenantListPageState();
}

class _ApprenantListPageState extends State<ApprenantListPage> {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Variables pour stocker les comptages
  int totalApprenants = 0;
  int totalFormateurs = 0;

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  // Méthode pour récupérer les comptages depuis Firestore
  Future<void> _fetchCounts() async {
    // Récupérer les documents qui ont le rôle "apprenant"
    final apprenantsCountSnapshot =
        await usersCollection.where('role', isEqualTo: 'apprenant').get();

    // Récupérer les documents qui ont le rôle "formateur"
    final formateursCountSnapshot =
        await usersCollection.where('role', isEqualTo: 'formateur').get();

    setState(() {
      totalApprenants = apprenantsCountSnapshot.size;
      totalFormateurs = formateursCountSnapshot.size;
    });
  }

  // Méthode pour afficher la boîte de dialogue de confirmation avant la suppression
  Future<void> _confirmDeleteApprenant(String id) async {
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
                Text('Êtes-vous sûr de vouloir supprimer cet apprenant ?'),
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
                await _deleteApprenant(id);
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
            ),
          ],
        );
      },
    );
  }

  // Méthode pour supprimer un apprenant
  Future<void> _deleteApprenant(String id) async {
    await usersCollection
        .doc(id)
        .delete(); // Utilisation de la collection "users"
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Apprenant supprimé avec succès')),
    );
  }

  // Méthode pour afficher le formulaire de modification
  void _showEditForm(DocumentSnapshot apprenant) {
    final TextEditingController nameController =
        TextEditingController(text: apprenant['name']);
    final TextEditingController surnameController =
        TextEditingController(text: apprenant['surname']);
    final TextEditingController emailController =
        TextEditingController(text: apprenant['email']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier Apprenant'),
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
                // Mise à jour des données de l'apprenant
                await usersCollection.doc(apprenant.id).update({
                  'name': nameController.text.trim(),
                  'surname': surnameController.text.trim(),
                  'email': emailController.text.trim(),
                });

                Navigator.of(context).pop(); // Fermer le formulaire
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Apprenant modifié avec succès')),
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
        title: Center(child: Text('Liste des Apprenants')),
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
                      'Total Apprenants',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(totalApprenants.toString()),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Filtrer pour récupérer uniquement les apprenants
              stream: usersCollection
                  .where('role', isEqualTo: 'apprenant')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Une erreur s\'est produite'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final apprenants = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: apprenants.length,
                  itemBuilder: (context, index) {
                    final apprenant = apprenants[index];

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: FaIcon(FontAwesomeIcons.userGraduate,
                            color: Couleurs.premierCouleur),
                        title: Text(
                            '${apprenant['name']} ${apprenant['surname']}'),
                        subtitle: Text(apprenant['email']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: FaIcon(FontAwesomeIcons.edit,
                                  color: Couleurs.premierCouleur),
                              onPressed: () => _showEditForm(apprenant),
                            ),
                            IconButton(
                              icon: FaIcon(FontAwesomeIcons.trashAlt,
                                  color: Couleurs.premierCouleur),
                              onPressed: () => _confirmDeleteApprenant(apprenant
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
