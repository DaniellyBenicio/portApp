import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Adiciona um novo usuário na subcoleção apropriada
  Future<void> addUser({
    required String email,
    required String nome,
    required String tipo, // 'aluno' ou 'professor'
    String? infoAdicional, // Ano de ingresso ou formação (opcional)
  }) async {
    try {
      // Valida o tipo de usuário
      if (tipo != 'Aluno' && tipo != 'Professor') {
        throw ArgumentError('Tipo de usuário inválido. Use "Aluno" ou "Professor".');
      }

      // Adiciona o usuário na subcoleção correta
      await _db
          .collection('Usuarios')
          .doc(tipo)
          .collection('lista')
          .add({
            'email': email,
            'nome': nome,
            'infoAdicional': infoAdicional ?? '', // Valor padrão se não fornecido
          });
      print('Usuário adicionado com sucesso.');
    } catch (e) {
      print('Erro ao adicionar usuário: $e');
    }
  }

  // Obtém todos os usuários de uma subcoleção específica
  Stream<List<Map<String, dynamic>>> getUsers(String tipo) {
    // Valida o tipo de usuário
    if (tipo != 'Aluno' && tipo != 'Professor') {
      throw ArgumentError('Tipo de usuário inválido. Use "Aluno" ou "Professor".');
    }

    return _db
        .collection('Usuarios')
        .doc(tipo)
        .collection('lista')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
  }
}
