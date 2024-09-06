import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:gestion_de_ticket/couleur/couleur.dart';

import '../apprenant/registrerApprenant.dart';
import '../chat/discussionListe.dart';
import '../ticket/categorie.dart';
import 'formateur_accueil.dart';

class Formateur extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Formateur> {
  int _selectedIndex = 0;
  // Liste des pages associées à chaque icône de navigation
  final List<Widget> _pages = [
    ApprenantListPage(), // liste des apprenants
    ApprenantRegister(),
    CategoriesPage(),
  ];

  static get uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          'Page d\'Accueil Formateur',
          style: TextStyle(color: Colors.white),
        )),
        backgroundColor: Couleurs.premierCouleur,
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60.0,
        items: <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.info, size: 30, color: Colors.white),
          Icon(Icons.chat, size: 30, color: Colors.white),
        ],
        color: Couleurs.premierCouleur,
        buttonBackgroundColor: Couleurs.secodeCouleur,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 100),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}
