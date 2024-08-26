import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Adiciona um novo usuário na subcoleção apropriada
  Future<void> addUser(String email, String nome, String tipo, String infoAdicional) async {
    try {
      // Define a coleção e o documento com base no tipo de usuário
      String collectionPath = tipo == 'aluno' ? 'alunos/lista' : 'professores/lista';

      // Adiciona o usuário na subcoleção correta
      await _db.collection('Usuarios').doc(tipo).collection('lista').add({
        'email': email,
        'nome': nome,
        'infoAdicional': infoAdicional, // Ano de ingresso ou formação
      });
      print('Usuário adicionado com sucesso.');
    } catch (e) {
      print('Erro ao adicionar usuário: $e');
    }
  }

  // Obtém todos os usuários de uma subcoleção específica
  Stream<List<Map<String, dynamic>>> getUsers(String tipo) {
    String collectionPath = tipo == 'aluno' ? 'alunos/lista' : 'professores/lista';

    return _db.collection('Usuarios').doc(tipo).collection('lista').snapshots().map((snapshot) => snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList());
  }
}
