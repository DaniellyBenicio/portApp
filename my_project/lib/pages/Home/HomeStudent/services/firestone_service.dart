import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, String>?> getNomeAndImageByEmail(String email) async {
    try {
      final snapshot = await _db.collection('users').where('email', isEqualTo: email).get();
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return {
          'nome': data['nome'] ?? '',
          'profileImageUrl': data['profileImageUrl'] ?? '',
        };
      }
    } catch (e) {
      print('Erro ao buscar dados do usuário: $e');
    }
    return null;
  }
}