import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AlunoDisciplinesPage extends StatefulWidget {
  @override
  _AlunoDisciplinesPageState createState() => _AlunoDisciplinesPageState();
}

class _AlunoDisciplinesPageState extends State<AlunoDisciplinesPage> {
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  List<Map<String, dynamic>> disciplinas = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _recuperarDisciplinasMatriculadas();
  }

  Future<void> _matricularAluno(String disciplinaId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('Usuário não autenticado');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('Matriculas').add({
        'alunoUid': user.uid,
        'disciplinaId': disciplinaId,
      });
      _showSnackBar('Matriculado na disciplina com sucesso!');
      await _recuperarDisciplinasMatriculadas();
    } catch (e) {
      _handleError('Erro ao matricular aluno', e);
    }
  }

  Future<void> _recuperarDisciplinasMatriculadas() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    disciplinas.clear();
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Matriculas')
          .where('alunoUid', isEqualTo: user.uid)
          .get();

      for (var doc in snapshot.docs) {
        final disciplinaId = doc['disciplinaId'];
        final disciplinaSnapshot = await FirebaseFirestore.instance
            .collection('Disciplinas')
            .doc(disciplinaId)
            .get();

        if (disciplinaSnapshot.exists) {
          disciplinas.add({
            'id': disciplinaSnapshot.id,
            ...disciplinaSnapshot.data() as Map<String, dynamic>,
          });
        }
      }
      setState(() {});
    } catch (e) {
      _handleError('Erro ao recuperar disciplinas matriculadas', e);
    }
  }

  Future<void> _buscarDisciplinasPorNome() async {
    final nomeDisciplina = nomeController.text.trim();
    if (nomeDisciplina.isEmpty) {
      _showSnackBar('Por favor, insira um nome de disciplina');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackBar('Usuário não autenticado');
        return;
      }

      final matriculasSnapshot = await FirebaseFirestore.instance
          .collection('Matriculas')
          .where('alunoUid', isEqualTo: user.uid)
          .get();

      if (matriculasSnapshot.docs.isEmpty) {
        _showSnackBar('Você não está matriculado em nenhuma disciplina.');
        return;
      }

      final List<String> disciplinaIds = matriculasSnapshot.docs
          .map((doc) => doc['disciplinaId'] as String)
          .toList();

      final snapshot = await FirebaseFirestore.instance
          .collection('Disciplinas')
          .where('nome', isEqualTo: nomeDisciplina)
          .where(FieldPath.documentId, whereIn: disciplinaIds)
          .get();

      if (snapshot.docs.isNotEmpty) {
        disciplinas = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          };
        }).toList();
        nomeController.clear();
      } else {
        _showSnackBar('Disciplina não encontrada entre suas disciplinas matriculadas.');
      }
    } catch (e) {
      _handleError('Erro ao buscar disciplinas', e);
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _buscarDisciplinaPorCodigo() async {
    final codigoAcesso = codigoController.text.trim();
    if (codigoAcesso.isEmpty) {
      _showSnackBar('Por favor, insira um código de acesso');
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackBar('Usuário não autenticado');
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('Disciplinas')
          .where('codigoAcesso', isEqualTo: codigoAcesso)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final disciplina = {
          'id': snapshot.docs.first.id,
          ...snapshot.docs.first.data() as Map<String, dynamic>,
        };
        await _matricularAluno(disciplina['id']);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisciplinaDetalhesPage(disciplina: disciplina),
          ),
        );
        codigoController.clear();
      } else {
        _showSnackBar('Código de acesso inválido ou disciplina não encontrada');
      }
    } catch (e) {
      _handleError('Erro ao buscar disciplina', e);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handleError(String message, dynamic error) {
    print('$message: ${error.runtimeType}: $error');
    _showSnackBar('$message: ${error.toString()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Disciplinas')),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Busque por disciplina',
                      suffixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: loading ? null : _buscarDisciplinasPorNome,
                    child: loading ? const LinearProgressIndicator() : const Text('Buscar'),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: disciplinas.isNotEmpty
                        ? ListView.builder(
                            itemCount: disciplinas.length,
                            itemBuilder: (context, index) {
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(disciplinas[index]['nome']),
                                  subtitle: Text(disciplinas[index]['descricao']),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DisciplinaDetalhesPage(disciplina: disciplinas[index]),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          )
                        : const Center(child: Text('Você ainda não está matriculado em nenhuma disciplina.')),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Entrar em uma Disciplina pelo Código', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: codigoController,
                    decoration: const InputDecoration(
                      labelText: 'Código de Acesso',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _buscarDisciplinaPorCodigo,
                    child: const Text('Entrar na Disciplina'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DisciplinaDetalhesPage extends StatelessWidget {
  final Map<String, dynamic> disciplina;

  const DisciplinaDetalhesPage({Key? key, required this.disciplina}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(disciplina['nome']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descrição: ${disciplina['descricao']}', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            // Outras informações da disciplina podem ser exibidas aqui.
          ],
        ),
      ),
    );
  }
}
