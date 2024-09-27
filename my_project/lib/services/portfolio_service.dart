import 'package:cloud_firestore/cloud_firestore.dart';

class PortfolioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
Future<List<Map<String, dynamic>>> getPortfolios(String disciplinaId, DocumentSnapshot? lastDocument, String userUid) async {
  Query query = _firestore
      .collection('Disciplinas')
      .doc(disciplinaId)
      .collection('Portfolios')
      .orderBy('dataCriacao', descending: true);

  if (lastDocument != null) {
    query = query.startAfterDocument(lastDocument);
  }

  QuerySnapshot querySnapshot = await query.limit(10).get();

  // Verificar quais documentos foram retornados antes de filtrar
  print('Documentos retornados: ${querySnapshot.docs.length}');

  return querySnapshot.docs.where((doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Adicionando uma verificação apenas para o professor
    return data['professorUid'] == userUid; // Retornar apenas se for o professor
  }).map((doc) => {
    'id': doc.id,
    ...doc.data() as Map<String, dynamic>
  }).toList();
}

  /// Método para adicionar um portfólio a uma disciplina
  Future<String> adicionarPortfolio({
    required String disciplinaId,
    required String titulo,
    required String descricao,
    required String professorUid,
  }) async {
    if (titulo.isEmpty || descricao.isEmpty || professorUid.isEmpty) {
      throw Exception('Título, descrição e UID do professor são obrigatórios.');
    }

    try {
      final DocumentReference docRef = await _firestore.collection('Disciplinas')
          .doc(disciplinaId)
          .collection('Portfolios')
          .add({
        'titulo': titulo,
        'descricao': descricao,
        'professorUid': professorUid,
        'dataCriacao': FieldValue.serverTimestamp(),
      });
      return docRef.id; 
    } catch (e) {
      print('Erro ao adicionar portfólio: $e');
      throw Exception('Erro ao adicionar portfólio: $e');
    }
  }

  /// Método para obter detalhes de um portfólio específico
  Future<Map<String, dynamic>> getPortfolioDetails(String disciplinaId, String portfolioId) async {
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('Disciplinas')
          .doc(disciplinaId)
          .collection('Portfolios')
          .doc(portfolioId)
          .get();

      if (snapshot.exists) {
        return {
          'id': snapshot.id,
          ...snapshot.data() as Map<String, dynamic>
        };
      } else {
        throw Exception('Portfólio não encontrado');
      }
    } catch (e) {
      print('Erro ao obter detalhes do portfólio: $e');
      throw Exception('Erro ao obter detalhes do portfólio: $e');
    }
  }

  /// Método para adicionar um arquivo a um portfólio
  Future<void> adicionarArquivoAoPortfolio({
    required String disciplinaId,
    required String portfolioId,
    required String alunoUid,
    required Map<String, dynamic> arquivoData,
  }) async {
    final matriculas = await _firestore.collection('Matriculas')
        .where('alunoUid', isEqualTo: alunoUid)
        .where('disciplinaId', isEqualTo: disciplinaId) 
        .get();

    if (matriculas.docs.isEmpty) {
      throw Exception('Aluno não matriculado na disciplina correspondente.');
    }

    try {
      await _firestore
          .collection('Disciplinas')
          .doc(disciplinaId)
          .collection('Portfolios')
          .doc(portfolioId)
          .collection('Arquivos')
          .add({
        'alunoUid': alunoUid,
        'dataUpload': FieldValue.serverTimestamp(),
        ...arquivoData,
      });
    } catch (e) {
      print('Erro ao adicionar arquivo ao portfólio: $e');
      throw Exception('Erro ao adicionar arquivo ao portfólio: $e');
    }
  }
}
