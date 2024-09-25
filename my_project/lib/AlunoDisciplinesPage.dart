import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Página principal para exibir as disciplinas do aluno
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
      print('Erro ao matricular aluno: ${e.runtimeType}: $e');
      _showSnackBar('Erro ao matricular aluno: ${e.toString()}');
    }
  }

  Future<void> _recuperarDisciplinasMatriculadas() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    disciplinas.clear();
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Matriculas')
          .where('alunoUid', isEqualTo: user.uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
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
      }
      setState(() {});
    } catch (e) {
      print('Erro ao recuperar disciplinas matriculadas: ${e.runtimeType}: $e');
      _showSnackBar('Erro ao recuperar disciplinas matriculadas: ${e.toString()}');
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

      final snapshot = await FirebaseFirestore.instance
          .collection('Disciplinas')
          .where('nome', isEqualTo: nomeDisciplina)
          .where('professorUid', isEqualTo: user.uid)
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
        _showSnackBar('Disciplina não encontrada');
      }
    } catch (e) {
      print('Erro ao buscar disciplinas: ${e.runtimeType}: $e');
      _showSnackBar('Erro ao buscar disciplinas: ${e.toString()}');
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
      print('Erro ao buscar disciplina: ${e.runtimeType}: $e');
      _showSnackBar('Erro ao buscar disciplina: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                    child: loading ? const CircularProgressIndicator() : const Text('Buscar'),
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
            // Entrar em uma disciplina pelo código
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

// Página para exibir os detalhes da disciplina
class DisciplinaDetalhesPage extends StatelessWidget {
  final Map<String, dynamic> disciplina;

  const DisciplinaDetalhesPage({Key? key, required this.disciplina}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(disciplina['nome']),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(disciplina['descricao'], style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Tarefas:', style: TextStyle(fontSize: 18)),
            // Aqui você pode adicionar mais detalhes sobre as tarefas da disciplina
          ],
        ),
      ),
    );
  }
}
