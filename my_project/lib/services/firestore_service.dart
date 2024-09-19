import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Adiciona um novo usuário diretamente na coleção 'Usuarios'
  Future<void> addUser({
    required String email,
    required String nome,
    required String tipo, // 'Aluno' ou 'Professor'
    String? infoAdicional,
  }) async {
    try {
      // Valida o tipo de usuário
      if (tipo != 'Aluno' && tipo != 'Professor') {
        throw ArgumentError('Tipo de usuário inválido. Use "Aluno" ou "Professor".');
      }

      await _db.collection('Usuarios').add({
        'email': email,
        'nome': nome,
        'tipo': tipo,
        'infoAdicional': infoAdicional ?? '',
      });
      print('Usuário adicionado com sucesso.');
    } catch (e) {
      print('Erro ao adicionar usuário: $e');
    }
  }

  // Obtém todos os usuários de um tipo específico
  Stream<List<Map<String, dynamic>>> getUsers(String tipo) {
    if (tipo != 'Aluno' && tipo != 'Professor') {
      throw ArgumentError('Tipo de usuário inválido. Use "Aluno" ou "Professor".');
    }

    return _db
        .collection('Usuarios')
        .where('tipo', isEqualTo: tipo)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
  }

  // Adiciona ou atualiza um usuário com um ID específico (por exemplo, UID)
  Future<void> upsertUser({
    required String uid, // UID do usuário
    required String email,
    required String nome,
    required String tipo,
    String? infoAdicional,
  }) async {
    try {
      if (tipo != 'Aluno' && tipo != 'Professor') {
        throw ArgumentError('Tipo de usuário inválido. Use "Aluno" ou "Professor".');
      }

      await _db.collection('Usuarios').doc(uid).set({
        'email': email,
        'nome': nome,
        'tipo': tipo,
        'infoAdicional': infoAdicional ?? '',
      }, SetOptions(merge: true)); // Use merge para atualizar campos existentes
      print('Usuário atualizado com sucesso.');
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
    }
  }

  Future<String?> getDocumentIdByEmail(String email) async {
    try {
      final querySnapshot = await _db
          .collection('Usuarios')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        print('Documento não encontrado para o email fornecido.');
        return null;
      }
    } catch (e) {
      print('Erro ao obter ID do documento pelo email: $e');
      return null;
    }
  }
}
