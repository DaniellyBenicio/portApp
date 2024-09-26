import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './services/firebase_service.dart';
import './widgets/custom_snackbar.dart';
import 'disciplina_detalhes_page.dart';

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
      handleError('Erro ao recuperar disciplinas matriculadas', e);
    }
  }

  Future<void> _buscarDisciplinasPorNome() async {
    final nomeDisciplina = nomeController.text.trim();
    if (nomeDisciplina.isEmpty) {
      showSnackBar(context, 'Por favor, insira um nome de disciplina');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showSnackBar(context, 'Usuário não autenticado');
        return;
      }

      final matriculasSnapshot = await FirebaseFirestore.instance
          .collection('Matriculas')
          .where('alunoUid', isEqualTo: user.uid)
          .get();

      if (matriculasSnapshot.docs.isEmpty) {
        showSnackBar(context, 'Você não está matriculado em nenhuma disciplina.');
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
        showSnackBar(context, 'Disciplina não encontrada entre suas disciplinas matriculadas.');
      }
    } catch (e) {
      handleError('Erro ao buscar disciplinas', e);
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _buscarDisciplinaPorCodigo() async {
    final codigoAcesso = codigoController.text.trim();
    if (codigoAcesso.isEmpty) {
      showSnackBar(context, 'Por favor, insira um código de acesso');
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showSnackBar(context, 'Usuário não autenticado');
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
        await matricularAluno(disciplina['id']);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisciplinaDetalhesPage(disciplina: disciplina),
          ),
        );
        codigoController.clear();
      } else {
        showSnackBar(context, 'Código de acesso inválido ou disciplina não encontrada');
      }
    } catch (e) {
      handleError('Erro ao buscar disciplina', e);
    }
  }

  void _showAddDisciplinaDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Disciplina'),
          content: TextField(
            controller: codigoController,
            decoration: const InputDecoration(
              labelText: 'Código de Acesso',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _buscarDisciplinaPorCodigo();
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Disciplinas',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Inter',
                fontSize: 36,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w600,
                height: 1.0,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Adicionar Disciplina',
              color: Colors.green,
              onPressed: _showAddDisciplinaDialog,
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey,
            height: 1.0,
          ),
        ),
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
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: loading ? null : _buscarDisciplinasPorNome,
                    child: loading ? const LinearProgressIndicator() : const Text('Buscar'),
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: disciplinas.isNotEmpty
                        ? ListView.builder(
                            itemCount: disciplinas.length,
                            itemBuilder: (context, index) {
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
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
          ],
        ),
      ),
    );
  }
}