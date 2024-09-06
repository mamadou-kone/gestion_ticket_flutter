import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final String surname;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.surname,
  });

  // Constructeur à partir d'un Map (par exemple, de Firestore)
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return User(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? '',
      surname: data['surname'] ?? '',
    );
  }
}
