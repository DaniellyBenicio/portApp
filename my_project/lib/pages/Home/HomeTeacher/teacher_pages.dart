import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_project/services/firestore_service.dart';
import 'package:my_project/pages/Home/HomeTeacher/widgets/custom_avatar.dart';

class TeacherPortfolioPage extends StatefulWidget {
  const TeacherPortfolioPage({super.key});

  @override
  _TeacherPortfolioPageState createState() => _TeacherPortfolioPageState();
}

class _TeacherPortfolioPageState extends State<TeacherPortfolioPage> {
  final FirestoreService _firestoreService = FirestoreService();
  String? _teacherName;
  String? profileImageUrl;
  bool _isLoading = true; // Variável para controle de loading
  List<Map<String, dynamic>> _disciplinas = []; // Lista para armazenar disciplinas

  @override
  void initState() {
    super.initState();
    _fetchTeacherData();
    _fetchDisciplinas(); // Chama o método para buscar disciplinas ao iniciar
  }

  Future<void> _fetchTeacherData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email ?? "";
        Map<String, String>? userData = await _firestoreService.getNomeAndImageByEmail(email);
        if (userData != null) {
          String fullName = userData['nome'] ?? 'Professor';
          List<String> nameParts = fullName.split(' ');
          String firstName = nameParts.length >= 2
              ? '${nameParts[0]} ${nameParts[1]}'
              : nameParts[0];

          setState(() {
            _teacherName = firstName;
            profileImageUrl = userData['profileImageUrl'] ?? '';
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDisciplinas() async {
    try {
      String? professorUid = FirebaseAuth.instance.currentUser?.uid; // Obtém o UID do professor
      List<Map<String, dynamic>> disciplinas = await _firestoreService.getDisciplinasPorProfessor(professorUid!);
      setState(() {
        _disciplinas = disciplinas;
      });
    } catch (e) {
      print('Erro ao buscar disciplinas: $e');
    }
  }

  void _showAddDisciplinaDialog() {
    final TextEditingController nomeController = TextEditingController();
    final TextEditingController descricaoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Disciplina'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome da Disciplina'),
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
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                String? professorUid = FirebaseAuth.instance.currentUser?.uid; // Obtém o UID do professor
                String? codigoAcesso = await _firestoreService.addDisciplina(
                  nome: nomeController.text,
                  descricao: descricaoController.text,
                  professorUid: professorUid ?? '',
                );
                if (codigoAcesso != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Disciplina adicionada com sucesso! Código de acesso: $codigoAcesso')),
                  );
                  _fetchDisciplinas(); // Atualiza a lista após adicionar
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao adicionar disciplina')),
                  );
                }
                Navigator.of(context).pop(); // Fecha o diálogo após adicionar
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  // Método para editar disciplina
  void _showEditDisciplinaDialog(String disciplinaId, String nome, String descricao) {
    final TextEditingController nomeController = TextEditingController(text: nome);
    final TextEditingController descricaoController = TextEditingController(text: descricao);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Disciplina'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Disciplina',
                  filled: false,
                  labelStyle: TextStyle(
                    color: Color.fromRGBO(18, 86, 143, 1), // Cor do texto do rótulo
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black, // Cor do texto digitado
                ),
              ),
              TextField(
                controller: descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  filled: false,
                  labelStyle: TextStyle(
                    color: Color.fromRGBO(18, 86, 143, 1), // Cor do texto do rótulo
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black, // Cor do texto digitado
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Color.fromRGBO(18, 86, 143, 1), // Cor de texto azul
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                String? professorUid = FirebaseAuth.instance.currentUser?.uid; // Obtém o UID do professor
                await _firestoreService.editarDisciplina(
                  disciplinaId: disciplinaId,
                  novoNome: nomeController.text,
                  novaDescricao: descricaoController.text,
                  professorUid: professorUid ?? '',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Disciplina editada com sucesso!')),
                );
                _fetchDisciplinas(); // Atualiza a lista após editar
                Navigator.of(context).pop(); // Fecha o diálogo após editar
              },
              child: const Text(
                'Salvar',
                style: TextStyle(
                  color: Color.fromRGBO(18, 86, 143, 1), // Cor de texto azul
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Método para excluir disciplina
  void _showDeleteConfirmationDialog(String disciplinaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Disciplina'),
          content: const Text('Tem certeza que deseja excluir esta disciplina?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Color.fromRGBO(18, 86, 143, 1), // Cor de texto azul
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                String? professorUid = FirebaseAuth.instance.currentUser?.uid; // Obtém o UID do professor
                await _firestoreService.excluirDisciplina(
                  disciplinaId: disciplinaId,
                  professorUid: professorUid ?? '',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Disciplina excluída com sucesso!')),
                );
                _fetchDisciplinas(); // Atualiza a lista após excluir
                Navigator.of(context).pop(); // Fecha o diálogo após excluir
              },
              child: const Text(
                'Excluir',
                style: TextStyle(
                  color: Color.fromRGBO(18, 86, 143, 1), // Cor de texto azul
                ),
              ),
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
          children: [
            CustomAvatar(
              profileImageUrl: profileImageUrl,
              teacherName: _teacherName,
            ),
            const SizedBox(width: 10),
            Text(_teacherName ?? 'Carregando...'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Exibe um loader enquanto carrega os dados
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Divider(), // Linha de divisão após o AppBar
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Disciplinas',
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(18, 86, 143, 1), // Cor de fundo azul
                          ),
                          onPressed: _showAddDisciplinaDialog, // Chama o método para adicionar disciplina
                          child: const Text(
                            'Adicionar',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_disciplinas.isEmpty)
                    Center( // Centraliza o texto
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Nenhuma disciplina cadastrada. Clique em Adicionar para cadastrar nova disciplina.',
                          style: TextStyle(color: Colors.grey.shade600),
                          textAlign: TextAlign.center, // Alinha o texto ao centro
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true, // Permite que o ListView tenha um tamanho fixo
                      physics: const NeverScrollableScrollPhysics(), // Desabilita a rolagem do ListView
                      itemCount: _disciplinas.length,
                      itemBuilder: (context, index) {
                        final disciplina = _disciplinas[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              // Adicionar lógica de abrir disciplina específica.
                              print('Disciplina clicada: ${disciplina['nome']}');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              child: ListTile(
                                title: Text(disciplina['nome']),
                                subtitle: Text(disciplina['descricao']),
                                trailing: PopupMenuButton<String>(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0), // Adiciona border radius
                                  ),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showEditDisciplinaDialog(disciplina['id'], disciplina['nome'], disciplina['descricao']); // Passa os dados para editar
                                    } else if (value == 'delete') {
                                      _showDeleteConfirmationDialog(disciplina['id']); // Chama o método para excluir disciplina
                                    } // Implemtar a lógica de enviar convite
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      const PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Text('Editar'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Text('Excluir'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'enviar',
                                        child: Text('Enviar Convite'),
                                      ),
                                    ];
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}