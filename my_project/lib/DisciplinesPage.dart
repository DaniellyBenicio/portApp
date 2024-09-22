import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_project/services/firestore_service.dart';
import 'package:flutter/services.dart';
import 'ActivitiesPage.dart';

class DisciplinesPage extends StatefulWidget {
  @override
  _DisciplinesPageState createState() => _DisciplinesPageState();
}

class _DisciplinesPageState extends State<DisciplinesPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> disciplinas = [];
  String? professorUid;

  @override
  void initState() {
    super.initState();
    _getCurrentUserUid(); // Busca o UID do professor ao iniciar
    _fetchDisciplinas();
  }

  void _getCurrentUserUid() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      professorUid = user.uid; // Armazena o UID do professor autenticado
      print(professorUid);
    } else {
      print('Nenhum usuário autenticado');
    }
  }

  Future<void> _fetchDisciplinas() async {
    if (professorUid == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Disciplinas')
          .where('professorUid', isEqualTo: professorUid) // Filtra pelas disciplinas do professor
          .get();

      setState(() {
        disciplinas = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'codigoAcesso': doc.data()['codigoAcesso'] ?? '',
            ...doc.data() as Map<String, dynamic>,
          };
        }).toList();
      });
    } catch (e) {
      print('Erro ao buscar disciplinas: $e');
    }
  }

  void _criarDisciplina() {
    final TextEditingController nomeController = TextEditingController();
    final TextEditingController descricaoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Criar Nova Disciplina'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: descricaoController,
                decoration: InputDecoration(labelText: 'Descrição'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (nomeController.text.isEmpty || descricaoController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Nome e descrição são obrigatórios!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                if (professorUid == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Usuário não autenticado!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                String? codigoAcesso = await _firestoreService.addDisciplina(
                  nome: nomeController.text,
                  descricao: descricaoController.text,
                  professorUid: professorUid!,
                );

                Navigator.of(context).pop();

                if (codigoAcesso != null) {
                  setState(() {
                    disciplinas.add({
                      'id': 'novo_id',
                      'nome': nomeController.text,
                      'descricao': descricaoController.text,
                      'codigoAcesso': codigoAcesso,
                    });
                  });
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Disciplina Criada'),
                        content: Container(
                          width: 200,
                          height: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SelectableText(
                                'Código de Acesso: $codigoAcesso',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              IconButton(
                                icon: Icon(Icons.copy),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: codigoAcesso));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Código copiado para a área de transferência!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                tooltip: 'Copiar Código',
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Disciplina criada com sucesso!'),
                      duration: Duration(seconds: 5),
                    ),
                  );
                }
              },
              child: Text('Criar'),
            ),
          ],
        );
      },
    );
  }

  void _editarDisciplina(Map<String, dynamic> disciplina) {
    final TextEditingController nomeController = TextEditingController(text: disciplina['nome']);
    final TextEditingController descricaoController = TextEditingController(text: disciplina['descricao']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Disciplina'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: descricaoController,
                decoration: InputDecoration(labelText: 'Descrição'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('Disciplinas').doc(disciplina['id']).update({
                  'nome': nomeController.text,
                  'descricao': descricaoController.text,
                });
                Navigator.of(context).pop();
                _fetchDisciplinas();
              },
              child: Text('Salvar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _deletarDisciplina(String disciplinaId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Você realmente deseja deletar esta disciplina?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('Disciplinas').doc(disciplinaId).delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Disciplina excluída com sucesso!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  _fetchDisciplinas();
                } catch (e) {
                  print('Erro ao deletar disciplina: $e');
                }
                Navigator.of(context).pop();
              },
              child: Text('Sim'),
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
        title: Center(child: Text('Disciplinas')),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: disciplinas.length,
          itemBuilder: (context, index) {
            final disciplina = disciplinas[index];
            return GestureDetector(
              onTap: () {
                // Navegar para a ActivitiesPage ao clicar na disciplina
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivitiesPage(disciplinaId: disciplina['id']),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        disciplina['nome'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        disciplina['descricao'],
                        textAlign: TextAlign.justify,
                      ),
                      SizedBox(height: 8),
                      if (disciplina['codigoAcesso'] != null && disciplina['codigoAcesso'].isNotEmpty) 
                        Text(
                          'Código de Acesso: ${disciplina['codigoAcesso']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editarDisciplina(disciplina),
                            tooltip: 'Editar',
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deletarDisciplina(disciplina['id']),
                            tooltip: 'Deletar',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _criarDisciplina,
        tooltip: 'Criar Disciplina',
        child: Icon(Icons.add),
      ),
    );
  }
}
