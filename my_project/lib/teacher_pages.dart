import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_project/services/firestore_service.dart';

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
      print('Erro ao buscar dados do professor: $e');
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

  void _showOptions(BuildContext context, String disciplinaId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar'),
                onTap: () {
                  // Lógica para editar a disciplina
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Excluir'),
                onTap: () async {
                  // Lógica para excluir a disciplina
                  await _firestoreService.getDisciplinasPorProfessor(disciplinaId); // Corrigi para usar o método de exclusão
                  _fetchDisciplinas(); // Atualiza a lista após exclusão
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                  ? NetworkImage(profileImageUrl!)
                  : null,
              backgroundColor: profileImageUrl == null || profileImageUrl!.isEmpty
                  ? const Color.fromRGBO(18, 86, 143, 1)
                  : Colors.transparent,
              child: profileImageUrl == null || profileImageUrl!.isEmpty
                  ? Text(
                      _teacherName?.substring(0, 1).toUpperCase() ?? 'P',
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(_teacherName ?? 'Carregando...'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Exibe um loader enquanto carrega os dados
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
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                  // Verifica se a lista de disciplinas está vazia
                  if (_disciplinas.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Você ainda não tem disciplinas cadastradas.',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    )
                  else
                    // Exibe a lista de disciplinas
                    ..._disciplinas.map((disciplina) {
                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.blue[100], // Cor de fundo da disciplina
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(disciplina['nome'] ?? 'Título aqui', style: const TextStyle(fontSize: 18)),
                            SizedBox(height: 4), // Espaço entre o nome e a descrição
                            Text(disciplina['descricao'] ?? 'Descrição aqui', style: const TextStyle(fontSize: 14)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () => _showOptions(context, disciplina['id']), // Passa o id da disciplina
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
    );
  }
}
