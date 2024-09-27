import 'package:cloud_firestore/cloud_firestore.dart';

class PortfolioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtém uma lista de portfólios com base na disciplina e na paginação.
  Future<List<Map<String, dynamic>>> getPortfolios(String disciplinaId, DocumentSnapshot? lastDocument) async {
    Query query = _firestore.collection('Portfolios')
        .where('disciplinaId', isEqualTo: disciplinaId)
        .orderBy('dataCriacao', descending: true);

    // Se houver um documento anterior, inicia a consulta a partir dele
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    // Limita a quantidade de documentos retornados para 10
    QuerySnapshot querySnapshot = await query.limit(10).get();

    // Retorna os dados dos documentos em formato de lista
    return querySnapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>
    }).toList();
  }

  /// Adiciona um novo portfólio à coleção.
  Future<String> adicionarPortfolio({
    required String disciplinaId,
    required String titulo,
    required String descricao,
    required String professorUid,
  }) async {
    // Valida os campos obrigatórios
    if (titulo.isEmpty || descricao.isEmpty || professorUid.isEmpty) {
      throw Exception('Título, descrição e UID do professor são obrigatórios.');
    }

    try {
      // Adiciona um novo portfólio na coleção
      final DocumentReference docRef = await _firestore.collection('Portfolios').add({
        'disciplinaId': disciplinaId,
        'titulo': titulo,
        'descricao': descricao,
        'professorUid': professorUid,
        'dataCriacao': FieldValue.serverTimestamp(),
      });
      return docRef.id; // Retorna o ID do novo portfólio criado
    } catch (e) {
      // Registra o erro e lança uma exceção
      print('Erro ao adicionar portfólio: $e');
      throw Exception('Erro ao adicionar portfólio: $e');
    }
  }

  /// Obtém os detalhes de um portfólio específico.
  Future<Map<String, dynamic>> getPortfolioDetails(String portfolioId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('Portfolios').doc(portfolioId).get();

      // Verifica se o documento existe e retorna os dados
      if (snapshot.exists) {
        return {
          'id': snapshot.id,
          ...snapshot.data() as Map<String, dynamic>
        };
      } else {
        throw Exception('Portfólio não encontrado'); // Lança uma exceção se o portfólio não existir
      }
    } catch (e) {
      // Registra o erro e lança uma exceção
      print('Erro ao obter detalhes do portfólio: $e');
      throw Exception('Erro ao obter detalhes do portfólio: $e');
    }
  }
}
