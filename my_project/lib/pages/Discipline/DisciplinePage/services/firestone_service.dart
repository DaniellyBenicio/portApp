import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> addDisciplina({required String nome, required String descricao, required String professorUid}) async {
    try {
      DocumentReference docRef = await _db.collection('Disciplinas').add({
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

  String _generateCodigoAcesso() {
    // Gera um código de acesso aleatório
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}