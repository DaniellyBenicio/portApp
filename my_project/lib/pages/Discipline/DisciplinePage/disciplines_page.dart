import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_project/services/firestore_service.dart';
import 'package:flutter/services.dart';
import 'portfolio_page.dart';
import './widgets/custom_snackbar.dart';

class DisciplinesPage extends StatefulWidget {
  @override
  _DisciplinesPageState createState() => _DisciplinesPageState();
}

class _DisciplinesPageState extends State<DisciplinesPage> {
  final FirestoreService _firestoreService = FirestoreService(); // Instância do serviço Firestore.
  List<Map<String, dynamic>> disciplinas = []; // Lista para armazenar as disciplinas.
  List<Map<String, dynamic>> disciplinasFiltradas = []; // Lista para armazenar as disciplinas filtradas.
  String? professorUid; // UID do professor autenticado.
  TextEditingController searchController = TextEditingController(); // Controlador para o campo de pesquisa.

  @override
  void initState() {
    super.initState();
    _getCurrentUserUid(); // Busca o UID do professor ao iniciar.
    _fetchDisciplinas(); // Carrega as disciplinas do professor.
    searchController.addListener(_filterDisciplinas); // Adiciona listener para o campo de pesquisa.
  }

  void _getCurrentUserUid() {
    User? user = FirebaseAuth.instance.currentUser; // Obtém o usuário autenticado
    if (user != null) {
      professorUid = user.uid; // Armazena o UID do professor autenticado
      print(professorUid);
    } else {
      print('Nenhum usuário autenticado');
    }
  }

  Future<void> _fetchDisciplinas() async { // Retorna se o UID não estiver disponível
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
            ...doc.data() as Map<String, dynamic>, // Extrai dados do documento
          };
        }).toList();
        disciplinasFiltradas = disciplinas; // Inicializa a lista filtrada com todas as disciplinas.
      });
    } catch (e) {
      print('Erro ao buscar disciplinas: $e');
    }
  }

  void _filterDisciplinas() {
    String query = searchController.text.toLowerCase();
    setState(() {
      disciplinasFiltradas = disciplinas.where((disciplina) {
        return disciplina['nome'].toLowerCase().contains(query) ||
               disciplina['descricao'].toLowerCase().contains(query);
      }).toList();
    });
  }

  void _criarDisciplina() {
    final TextEditingController nomeController = TextEditingController();
    final TextEditingController descricaoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Criar Nova Disciplina'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (nomeController.text.isEmpty || descricaoController.text.isEmpty) {
                  showSnackBar(context, 'Nome e descrição são obrigatórios!');
                  return;
                }

                if (professorUid == null) {
                  showSnackBar(context, 'Usuário não autenticado!');
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
                      'id': 'novo_id', // Adiciona nova disciplina à lista
                      'nome': nomeController.text,
                      'descricao': descricaoController.text,
                      'codigoAcesso': codigoAcesso,
                    });
                    _filterDisciplinas(); // Atualiza a lista filtrada.
                  });
                  // Exibe um diálogo com o código de acesso da nova disciplina
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Disciplina Criada'),
                        content: Container(
                          width: 200,
                          height: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SelectableText(
                                'Código de Acesso: $codigoAcesso',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: codigoAcesso));
                                  showSnackBar(context, 'Código copiado para a área de transferência!');
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
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );

                  showSnackBar(context, 'Disciplina criada com sucesso!');
                }
              },
              child: const Text('Criar'),
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
          title: const Text('Editar Disciplina'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
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
              child: const Text('Salvar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
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
          title: const Text('Confirmar Exclusão'),
          content: const Text('Você realmente deseja deletar esta disciplina?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('Disciplinas').doc(disciplinaId).delete();
                  showSnackBar(context, 'Disciplina excluída com sucesso!');
                  _fetchDisciplinas();
                } catch (e) {
                  print('Erro ao deletar disciplina: $e');
                }
                Navigator.of(context).pop();
              },
              child: const Text('Sim'),
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
        title: const Text(
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Pesquisar Disciplinas...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: disciplinasFiltradas.length,
          itemBuilder: (context, index) {
            final disciplina = disciplinasFiltradas[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PortfolioPage(
                      disciplinaId: disciplina['id'],
                      disciplinaNome: disciplina['nome'],
                    ),
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
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        disciplina['descricao'],
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 8),
                      if (disciplina['codigoAcesso'] != null && disciplina['codigoAcesso'].isNotEmpty)
                        Text(
                          'Código de Acesso: ${disciplina['codigoAcesso']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editarDisciplina(disciplina),
                            tooltip: 'Editar',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}