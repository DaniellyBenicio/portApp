import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';


class FirestoreService {//interação com o Firestore para gerenciamento de coleções 
  final FirebaseFirestore _db = FirebaseFirestore.instance;//Cria uma instancia para interagir com o BD

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

       //Adiciona o usuário à coleção 'Usuarios' com os campos especificados
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

  //Obtém todos os usuários de um tipo específico
  Stream<List<Map<String, dynamic>>> getUsers(String tipo) {
    if (tipo != 'Aluno' && tipo != 'Professor') {
      throw ArgumentError('Tipo de usuário inválido. Use "Aluno" ou "Professor".');
    }

    //Retorna um stream de usuários filtrados pelo tipo
    return _db
        .collection('Usuarios')
        .where('tipo', isEqualTo: tipo)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
  }

  //Adiciona ou atualiza um usuário com um ID específico (por exemplo, UID)
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

      //Adiciona ou atualiza o usuário com o UID fornecido
      await _db.collection('Usuarios').doc(uid).set({
        'email': email,
        'nome': nome,
        'tipo': tipo,
        'infoAdicional': infoAdicional ?? '',
      }, SetOptions(merge: true)); //Usa merge para atualizar campos existentes
      print('Usuário atualizado com sucesso.');
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
    }
  }

  //Método para obter o ID do documento de um usuário com base no e-mail
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

  // Método para obter o nome e a imagem de perfil do usuário com base no e-mail
  Future<Map<String, String>?> getNomeAndImageByEmail(String email) async {
    try {
      final querySnapshot = await _db
          .collection('Usuarios')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        return {
          'nome': data['nome'] ?? '',
          'profileImageUrl': data['profileImageUrl'] ?? '',
        };
      } else {
        print('Usuário não encontrado para o email fornecido.');
        return null;
      }
    } catch (e) {
      print('Erro ao obter dados do usuário pelo email: $e');
      return null;
    }
  }



  //Adiciona uma nova disciplina com uma chave de acesso
  Future<String?> addDisciplina({
  required String nome,
  required String descricao,
  required String professorUid,

  }) async {
    try {
      String codigoAcesso = _gerarCodigoAcesso();//Gera codigo de acesso
      await _db.collection('Disciplinas').add({
        'nome': nome,
        'descricao': descricao,
        'professorUid': professorUid,
        'codigoAcesso': codigoAcesso,
      });
      print('Disciplina adicionada com sucesso. Chave de acesso: $codigoAcesso');
      return codigoAcesso; 
    } catch (e) {
      print('Erro ao adicionar disciplina: $e');
      return null;
    }
  }
  //Gera uma chave de acesso aleatória
  String _gerarCodigoAcesso() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789#@_';
    final Random rand = Random();
    return List.generate(8, (index) => chars[rand.nextInt(chars.length)]).join();
  }

    // Método para obter as disciplinas de um professor pelo UID
  Future<List<Map<String, dynamic>>> getDisciplinasPorProfessor(String professorUid) async {
    try {
      final snapshot = await _db.collection('Disciplinas').where('professorUid', isEqualTo: professorUid).get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      print('Erro ao buscar disciplinas do professor: $e');
      return [];
    }
  }

  
  //Método para inscrever um aluno em uma disciplina
  Future<void> inscreverAluno(String disciplinaId, String alunoUid, String codigoAcesso) async {
  try {
    DocumentSnapshot disciplinaSnapshot = await _db.collection('Disciplinas').doc(disciplinaId).get();

    if (disciplinaSnapshot.exists) {
      String? codigoValido = disciplinaSnapshot['codigoAcesso'];
      if (codigoAcesso == codigoValido) {
        DocumentSnapshot alunoSnapshot = await _db.collection('Disciplinas').doc(disciplinaId).collection('alunos').doc(alunoUid).get();

        if (!alunoSnapshot.exists) {
          await _db.collection('Disciplinas').doc(disciplinaId).collection('alunos').doc(alunoUid).set({
            'status': 'inscrito',
            'dataInscricao': FieldValue.serverTimestamp(), // Armazena a data da inscrição
          });
          print('Aluno inscrito na disciplina com sucesso.');
        } else {
          print('Aluno já está inscrito nesta disciplina.');
        }
      } else {
        print('Chave de acesso inválida.');
      }
    } else {
      print('Disciplina não encontrada. ID: $disciplinaId'); 
    }
  } catch (e) {
    print('Erro ao inscrever aluno: $e');
  }
}

//Método para obter as disciplinas em que o aluno está matriculado
Future<List<Map<String, dynamic>>> getDisciplinasMatriculadas(String alunoUid) async {
  try {
    final snapshot = await _db.collection('Disciplinas').where('alunos.$alunoUid', isEqualTo: true).get();

    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    }).toList();
  } catch (e) {
    print('Erro ao buscar disciplinas matriculadas: $e');
    return [];
  }
}

//Método para adicionar uma atividade ou portfólio em uma disciplina - precisa mudar
Future<void> adicionarAtividadeOuPortfolio({
  required String disciplinaId,
  required String titulo,
  required String descricao,
  required String professorUid,
  required String tipoArquivo, 
  required bool isPortfolio, 
}) async {
  try {
    final collectionName = isPortfolio ? 'Portfolios' : 'Atividades';
    await _db.collection('Disciplinas')
      .doc(disciplinaId)
      .collection(collectionName)
      .add({
        'titulo': titulo,
        'descricao': descricao,
        'professorUid': professorUid,
        'tipoArquivo': tipoArquivo, // Adiciona o tipo de arquivo
      });
    print('Atividade/Portfólio adicionado com sucesso.');
  } catch (e) {
    print('Erro ao adicionar atividade/portfólio: $e');
  }
}


}
