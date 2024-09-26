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

  Future<List<Map<String, dynamic>>> getDisciplinasPorProfessor(String professorUid) async {
    try {
      final snapshot = await _db.collection('Disciplinas').where('professorUid', isEqualTo: professorUid).get();
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Erro ao buscar disciplinas: $e');
      return [];
    }
  }

  Future<String?> addDisciplina({required String nome, required String descricao, required String professorUid}) async {
    try {
      final docRef = await _db.collection('Disciplinas').add({
        'nome': nome,
        'descricao': descricao,
        'professorUid': professorUid,
        'codigoAcesso': _generateCodigoAcesso(),
      });
      return docRef.id;
    } catch (e) {
      print('Erro ao adicionar disciplina: $e');
      return null;
    }
  }

  Future<void> editarDisciplina({required String disciplinaId, required String novoNome, required String novaDescricao, required String professorUid}) async {
    try {
      await _db.collection('Disciplinas').doc(disciplinaId).update({
        'nome': novoNome,
        'descricao': novaDescricao,
        'professorUid': professorUid,
      });
    } catch (e) {
      print('Erro ao editar disciplina: $e');
    }
  }

  Future<void> excluirDisciplina({required String disciplinaId, required String professorUid}) async {
    try {
      await _db.collection('Disciplinas').doc(disciplinaId).delete();
    } catch (e) {
      print('Erro ao excluir disciplina: $e');
    }
  }

  String _generateCodigoAcesso() {
    // Gera um código de acesso aleatório
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}