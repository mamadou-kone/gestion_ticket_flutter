import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:gestion_de_ticket/couleur/couleur.dart';

import '../chat/discussionListe.dart';
import '../ticket/ticketEnvoi.dart';

class Apprenant extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Apprenant> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Center(child: Text('Accueil', style: TextStyle(fontSize: 24))),
    Center(child: Text('À Propos', style: TextStyle(fontSize: 24))),
    TicketsPage(currentUserId: uid)
  ];

  static get uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          'Page d\'Accueil apprenant',
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
          Icon(Icons.contact_mail, size: 30, color: Colors.white),
        ],
        color: Couleurs.premierCouleur,
        buttonBackgroundColor: Couleurs.secodeCouleur,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 500),
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
