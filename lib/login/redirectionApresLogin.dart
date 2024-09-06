import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../admin/admin.dart';
import '../apprenant/apprenant.dart';
import '../formateur/formateur.dart';

/// Widget de redirection après connexion en fonction du rôle utilisateur
class RedirectionApresLogin extends StatefulWidget {
  @override
  _RedirectionApresLoginState createState() => _RedirectionApresLoginState();
}

class _RedirectionApresLoginState extends State<RedirectionApresLogin> {
  User? _currentUser =
      FirebaseAuth.instance.currentUser; // Utilisateur connecté
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _fetchUserRole(); // Récupérer le rôle de l'utilisateur lors de l'initialisation
  }

  /// Récupère le rôle de l'utilisateur connecté depuis Firestore
  Future<void> _fetchUserRole() async {
    if (_currentUser != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

        if (userDoc.exists) {
          final role = userDoc.data()?['role']?.toLowerCase() ??
              'unknown'; // Forcer la casse en minuscules
          print(
              'Rôle récupéré : $role'); // Vérifiez cette valeur dans la console
          setState(() {
            _userRole = role;
          });
        } else {
          setState(() {
            _userRole = 'unknown';
          });
        }
      } catch (e) {
        print('Erreur lors de la récupération du rôle utilisateur : $e');
        setState(() {
          _userRole =
              'unknown'; // Définir un état de rôle inconnu en cas d'erreur
        });
      }
    } else {
      setState(() {
        _userRole = 'unknown'; // Utilisateur non connecté
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Afficher un indicateur de chargement pendant la récupération du rôle
    if (_userRole == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Rediriger vers la page appropriée en fonction du rôle de l'utilisateur
    switch (_userRole) {
      case 'admin':
        return Admin();
      case 'formateur':
        return Formateur();
      case 'apprenant':
        return Apprenant();
      default:
        return Scaffold(
          body: Center(
            child: Text(
              'Rôle inconnu : $_userRole. Veuillez contacter l\'administrateur.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        );
    }
  }
}
