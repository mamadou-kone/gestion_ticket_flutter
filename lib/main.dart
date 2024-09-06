import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gestion_de_ticket/login/login.dart';

import 'firebase_options.dart';
import 'login/registrer.dart'; // Import du fichier de configuration Firebase

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisez Firebase avec les options spécifiques à la plateforme
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue[900],
      ),
      home: LoginPage(),
    );
  }
}
