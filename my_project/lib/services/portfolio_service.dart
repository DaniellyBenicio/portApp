import 'package:cloud_firestore/cloud_firestore.dart';

class PortfolioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getPortfolios(String? disciplinaId, String alunoUid) async {
  try {
    if (disciplinaId != null) {
      
      // Consulta portfólios para a disciplina
      Query query = _firestore
          .collection('Disciplinas')
          .doc(disciplinaId)
          .collection('Portfolios')
          .orderBy('dataCriacao', descending: true);  // Removeu o filtro 'alunoUid', caso os portfólios sejam para todos os alunos

      QuerySnapshot querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      // Organiza os portfólios
      List<Map<String, dynamic>> portfolios = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'titulo': doc['titulo'],
          'dataCriacao': doc['dataCriacao'],
        };
      }).toList();
      return portfolios;

    } else {
      final matriculasSnapshot = await _firestore
          .collection('Matriculas')
          .where('alunoUid', isEqualTo: alunoUid)
          .get();

      List<String> disciplinaIds = matriculasSnapshot.docs.map((doc) => doc['disciplinaId'] as String).toList();

      if (disciplinaIds.isEmpty) {
        return [];
      }

      // Organiza os portfólios de todas as disciplinas
      List<Map<String, dynamic>> portfolios = [];

      for (String disciplinaId in disciplinaIds) {
        final portfoliosSnapshot = await _firestore
            .collection('Disciplinas')
            .doc(disciplinaId)
            .collection('Portfolios')
            .orderBy('dataCriacao', descending: true)
            .get();

        for (var doc in portfoliosSnapshot.docs) {
          portfolios.add({
            'id': doc.id,
            'titulo': doc['titulo'],
            'dataCriacao': doc['dataCriacao'],
          });
        }
      }
      return portfolios;
    }
  } catch (e) {
    return [];
  }
}


Future<String> adicionarPortfolio({
  required String disciplinaId,
  required String titulo,
  required String descricao,
  required String professorUid,
  required List<String> tipoArquivo,
  bool permitirComentario = false,
  bool permitirMultipleFiles = false,
}) async {
  // Validação de dados
  _validatePortfolioData(titulo, descricao, professorUid);

  try {
    // Cria o portfólio com alunoUids vazio e os novos campos
    final DocumentReference docRef = await _firestore.collection('Disciplinas')
        .doc(disciplinaId)
        .collection('Portfolios')
        .add({
      'titulo': titulo,
      'descricao': descricao,
      'professorUid': professorUid,
      'tipoArquivo': tipoArquivo,  // Salvando os novos parâmetros
      'permitirComentario': permitirComentario,
      'permitirMultipleFiles': permitirMultipleFiles,
      'dataCriacao': FieldValue.serverTimestamp(),
      'alunoUids': [] // Inicializa como lista vazia
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
    await _validateStudentEnrollment(alunoUid, disciplinaId);

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

  Future<void> excluirPortfolio({
    required String disciplinaId,
    required String portfolioId,
  }) async {
    try {
      // Verifica se o portfólio existe antes de tentar excluir
      DocumentSnapshot docSnapshot = await _firestore
          .collection('Disciplinas')
          .doc(disciplinaId)
          .collection('Portfolios')
          .doc(portfolioId)
          .get();

      if (docSnapshot.exists) {
      // Se o portfólio existir, realiza a exclusão
        await _firestore
            .collection('Disciplinas')
            .doc(disciplinaId)
            .collection('Portfolios')
            .doc(portfolioId)
            .delete();
        print('Portfólio excluído com sucesso.');
      } else {
        throw Exception('Portfólio não encontrado.');
      }
    } catch (e) {
      print('Erro ao excluir portfólio: $e');
      throw Exception('Erro ao excluir portfólio: $e');
    }
    }

    
  Future<void> editarPortfolio({
    required String disciplinaId,
    required String portfolioId,
    required String titulo,
    required String descricao,
    required List<String> tipoArquivo, // Lista de tipos de arquivos permitidos
    required bool permitirComentario, // Permitir ou não comentários
    required bool permitirMultipleFiles, // Permitir ou não múltiplos arquivos
  }) async {
    final updateData = {
      'titulo': titulo,
      'descricao': descricao,
      'tipoArquivo': tipoArquivo,
      'permitirComentario': permitirComentario,
      'permitirMultipleFiles': permitirMultipleFiles,
      'dataAtualizacao': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('Disciplinas')
        .doc(disciplinaId)
        .collection('Portfolios')
        .doc(portfolioId)
        .update(updateData);
  }

  // Adiciona os portfólios do snapshot à lista de portfólios
  void _addPortfolios(QuerySnapshot portfoliosSnapshot, List<Map<String, dynamic>> portfolios) {
    for (var doc in portfoliosSnapshot.docs) {
      portfolios.add({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>
      });
    }
  }

  // Filtra e mapeia os portfólios do snapshot para incluir apenas aqueles do professor especificado
  List<Map<String, dynamic>> _filterAndMapPortfolios(QuerySnapshot querySnapshot, String userUid) {
    return querySnapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['professorUid'] == userUid;
    }).map((doc) => {
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>
    }).toList();
  }

  // Valida os dados do portfólio, garantindo que título, descrição e UID do professor não estejam vazios
  void _validatePortfolioData(String titulo, String descricao, String professorUid) {
    if (titulo.isEmpty || descricao.isEmpty || professorUid.isEmpty) {
      throw Exception('Título, descrição e UID do professor são obrigatórios.');
    }
  }

  // Valida se o aluno está matriculado na disciplina especificada
  Future<void> _validateStudentEnrollment(String alunoUid, String disciplinaId) async {
    final matriculas = await _firestore.collection('Matriculas')
        .where('alunoUid', isEqualTo: alunoUid)
        .where('disciplinaId', isEqualTo: disciplinaId)
        .get();

    if (matriculas.docs.isEmpty) {
      throw Exception('Aluno não matriculado na disciplina correspondente.');
    }
  }

  Future<void> associarAlunoAoPortfolio(String alunoUid, String disciplinaId) async {
    try {
      // Primeiro, buscamos o portfólio da disciplina.
      QuerySnapshot portfolioSnapshot = await _firestore
          .collection('Portfolios')
          .where('disciplinaId', isEqualTo: disciplinaId)
          .get();

      // Verificamos se o portfólio existe.
      if (portfolioSnapshot.docs.isNotEmpty) {
        for (DocumentSnapshot portfolioDoc in portfolioSnapshot.docs) {
          // Obtemos o ID do portfólio.
          String portfolioId = portfolioDoc.id;

          // Verifica se o campo 'alunosUids' (um array de UIDs) já existe no portfólio
          List<dynamic> alunosUids = portfolioDoc['alunosUids'] ?? [];

          // Verifica se o UID do aluno já não está no array, para evitar duplicação
          if (!alunosUids.contains(alunoUid)) {
            // Adiciona o alunoUid ao array 'alunosUids' usando o método FieldValue.arrayUnion
            await _firestore.collection('Portfolios').doc(portfolioId).update({
              'alunosUids': FieldValue.arrayUnion([alunoUid])
            });
            print('Aluno $alunoUid associado ao portfólio $portfolioId com sucesso.');
          } else {
            print('Aluno $alunoUid já está associado ao portfólio $portfolioId.');
          }
        }
      } else {
        print('Nenhum portfólio encontrado para a disciplina: $disciplinaId');
      }
    } catch (e) {
      print('Erro ao associar aluno ao portfólio: $e');
      throw Exception('Erro ao associar aluno ao portfólio: $e');
    }
  }


  /// Salva ou atualiza um portfólio
  Future<void> salvarPortfolio({
    String? portfolioId,
    required String disciplinaId,
    required String titulo,
    required String descricao,
    required String professorUid,
    required List<String> tipoArquivo,
    required bool permitirComentario,
    required bool permitirMultipleFiles,
  }) async {
    final portfolioData = {
      'titulo': titulo,
      'descricao': descricao,
      'tipoArquivo': tipoArquivo,
      'permitirComentario': permitirComentario,
      'permitirMultipleFiles': permitirMultipleFiles,
      'professorUid': professorUid,
      'dataAtualizacao': FieldValue.serverTimestamp(),
    };

    final collectionRef = _firestore
        .collection('Disciplinas')
        .doc(disciplinaId)
        .collection('Portfolios');

    if (portfolioId == null) {
      // Caso o portfólio seja novo (inserção)
      portfolioData['dataCriacao'] = FieldValue.serverTimestamp();
      await collectionRef.add(portfolioData);
    } else {
      // Caso o portfólio já exista (atualização)
      await collectionRef.doc(portfolioId).update(portfolioData);
    }
  }
  
  
}
