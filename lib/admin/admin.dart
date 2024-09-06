import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:gestion_de_ticket/admin/registrerAdmin.dart';
import 'package:gestion_de_ticket/apprenant/registrerApprenant.dart';
import 'package:gestion_de_ticket/couleur/couleur.dart';
import '../chat/discussionListe.dart';
import '../formateur/registrerFormateur.dart';
import 'admin_accueil.dart';
import 'doashboard.dart';

class Admin extends StatefulWidget {
  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  int _selectedIndex = 0; // Indice de l'onglet sélectionné

  // Liste des pages associées à chaque icône de navigation
  final List<Widget> _pages = [
    DashboardPage(),
    FormateurListPage(), // Page d'accueil
    FormateurRegister(),
    ApprenantRegister(), // Page d'enregistrement des formateurs
    RegisterAdminForm(), // Page d'enregistrement des administrateurs
  ];

  get uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Couleurs.premierCouleur,
        title: Text('Bienvenue, Administrateur!',
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversationsPage(currentUserId: uid),
                ),
              );
            },
          ),
        ],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Couleurs.premierCouleur),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.dashboard,
                      size: 25, color: Couleurs.premierCouleur),
                  SizedBox(width: 10),
                  Text('Dashboard'),
                ],
              ),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.home, size: 25, color: Couleurs.premierCouleur),
                  SizedBox(width: 10),
                  Text('Accueil'),
                ],
              ),
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.person_add,
                      size: 25, color: Couleurs.premierCouleur),
                  SizedBox(width: 10),
                  Text('Enregistrer Formateur'),
                ],
              ),
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.person_add,
                      size: 25, color: Couleurs.premierCouleur),
                  SizedBox(width: 10),
                  Text('Enregistrer Apprenant'),
                ],
              ),
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.admin_panel_settings,
                      size: 25, color: Couleurs.premierCouleur),
                  SizedBox(width: 10),
                  Text('Enregistrer Administrateur'),
                ],
              ),
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 1000),
        child: _pages[_selectedIndex], // Affiche la page sélectionnée
      ),
    );
  }
}
