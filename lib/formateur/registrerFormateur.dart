import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_de_ticket/couleur/couleur.dart';

class FormateurRegister extends StatefulWidget {
  @override
  _FormateurRegisterState createState() => _FormateurRegisterState();
}

class _FormateurRegisterState extends State<FormateurRegister> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _registerTrainer() async {
    try {
      // Créer un utilisateur avec Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Obtenir l'UID de l'utilisateur créé
      String uid = userCredential.user!.uid;

      // Obtenir l'UID de l'admin actuellement connecté
      String? adminUid = FirebaseAuth.instance.currentUser?.uid;

      if (adminUid == null) {
        throw Exception("Aucun utilisateur connecté");
      }

      // Enregistrer le rôle "formateur" dans Firestore
      await FirebaseFirestore.instance.collection('formateur').doc(uid).set({
        'formateurId': uid,
        'adminId': adminUid, // Utiliser l'ID de l'admin connecté
      });

      // Enregistrer les informations de l'utilisateur avec le rôle et l'ID de l'admin dans Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'formateur',
      });

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Formateur enregistré avec succès')),
      );

      // Réinitialiser les champs du formulaire
      _nameController.clear();
      _surnameController.clear();
      _emailController.clear();
      _passwordController.clear();
    } catch (e) {
      // Gérer les erreurs et afficher un message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          'Ajouter un Formateur',
          style: TextStyle(
              color: Couleurs.premierCouleur, fontWeight: FontWeight.bold),
        )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _surnameController,
                decoration: InputDecoration(labelText: 'Prénom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prénom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un email';
                  } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un mot de passe';
                  } else if (value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  side: BorderSide(
                    color: Couleurs.premierCouleur,
                    width: 3.0,
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _registerTrainer();
                  }
                },
                child: Text(
                  'Enregistrer Formateur',
                  style: TextStyle(color: Couleurs.premierCouleur),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
