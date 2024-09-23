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
        nomeController.clear(); // Limpar campo após a busca
      } else {
        _showSnackBar('Disciplina não encontrada');
      }
    } catch (e) {
      print('Erro ao buscar disciplinas: $e');
      _showSnackBar('Erro ao buscar disciplinas');
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

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisciplinaDetalhesPage(disciplina: disciplina),
          ),
        );
        codigoController.clear(); // Limpar campo após a busca
      } else {
        _showSnackBar('Código de acesso inválido ou disciplina não encontrada');
      }
    } catch (e) {
      print('Erro ao buscar disciplina: $e');
      _showSnackBar('Erro ao buscar disciplina');
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
            // Parte de busca por nome
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
                    child: ListView.builder(
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
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Parte de busca por código de acesso
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
                  Expanded(
                    child: Center(
                      child: disciplinas.isEmpty
                          ? const Text('Você ainda não está matriculado em nenhuma disciplina.')
                          : Container(),
                    ),
                  ),
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
        title: Center(child: Text(disciplina['nome'])),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              disciplina['nome'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              disciplina['descricao'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Adicione uma ação para um botão, se necessário
              },
              child: const Text('Ação Adicional'),
            ),
          ],
        ),
      ),
    );
  }
}
