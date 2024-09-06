import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  Future<String?> getUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Utilisateur non connecté");
    }

    DocumentSnapshot<Map<String, dynamic>> roleDoc = await FirebaseFirestore
        .instance
        .collection('user_roles')
        .doc(user.uid)
        .get();

    return roleDoc.data()?['role'];
  }
}
