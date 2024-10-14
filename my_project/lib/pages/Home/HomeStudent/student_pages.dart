import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/services/portfolio_service.dart';
import 'package:my_project/services/firestore_service.dart';
import 'package:my_project/pages/Home/HomeStudent/widgets/custom_avatar.dart';

class StudentPortfolioPage extends StatefulWidget {
  const StudentPortfolioPage({super.key});

  @override
  _StudentPortfolioPageState createState() => _StudentPortfolioPageState();
}

class _StudentPortfolioPageState extends State<StudentPortfolioPage> {
  final PortfolioService _portfolioService = PortfolioService();
  final FirestoreService _firestoreService = FirestoreService(); 
  String? _studentName;
  String? profileImageUrl;
  bool _isLoading = true; // Variável para controle de loading
  List<Map<String, dynamic>> _portfolios = []; // Lista para armazenar os portfólios do aluno
  List<Map<String, dynamic>> _disciplinas = []; // Lista para armazenar as disciplinas
  String? _selectedDisciplina; // Disciplina selecionada

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String alunoUid = user.uid;

        // Buscar o nome e a imagem do perfil do aluno
        await _fetchStudentName();

        // Buscar portfólios e disciplinas usando o ID do aluno
        _portfolios = await _portfolioService.getPortfoliosForStudent(alunoUid);
        _disciplinas = await _fetchStudentDisciplinas(alunoUid); // Novo método para buscar disciplinas

        // Filtrar os portfólios pela disciplina selecionada após o carregamento inicial
        _filterPortfoliosByDisciplina();
      }
    } catch (e) {
      print('Erro ao carregar os dados do aluno: $e');
    } finally {
      setState(() {
        _isLoading = false; // Encerrar o loading
      });
    }
  }

  Future<void> _fetchStudentName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email ?? "";
        Map<String, String>? userData = await _firestoreService.getNomeAndImageByEmail(email); 

        if (userData != null && userData.isNotEmpty) {
          String fullName = userData['nome'] ?? 'Aluno';
          List<String> nameParts = fullName.split(' ');
          String firstName = nameParts.length >= 2
              ? '${nameParts[1]} ${nameParts[2]}'
              : nameParts[0];
          setState(() {
            _studentName = firstName;
            profileImageUrl = userData['profileImageUrl'] ?? '';
          });
        } else {
          setState(() {
            _studentName = 'Aluno';
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar o nome do aluno: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchStudentDisciplinas(String alunoUid) async {
    final matriculasSnapshot = await FirebaseFirestore.instance
        .collection('Matriculas')
        .where('alunoUid', isEqualTo: alunoUid)
        .get();

    // Obtenha todos os disciplinaIds
    List<String> disciplinaIds = matriculasSnapshot.docs.map((doc) => doc['disciplinaId'] as String).toList();

    // Busque informações das disciplinas
    List<Map<String, dynamic>> disciplinas = [];
    for (String disciplinaId in disciplinaIds) {
      var disciplinaDoc = await FirebaseFirestore.instance.collection('Disciplinas').doc(disciplinaId).get();
      if (disciplinaDoc.exists) {
        disciplinas.add({
          'id': disciplinaId,
          'nome': disciplinaDoc['nome'] 
        });
      }
    }

    return disciplinas;
  }

  void _filterPortfoliosByDisciplina() {
    // Se nenhuma disciplina estiver selecionada, mantenha todos os portfólios
    if (_selectedDisciplina != null) {
      setState(() {
        _portfolios = _portfolios.where((portfolio) {
          return portfolio['disciplinaId'] == _selectedDisciplina; 
        }).toList();
      });
    } else {
      // Se não houver disciplina selecionada, recarregue todos os portfólios
      _fetchStudentData();
    }
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
              studentName: _studentName,
            ),
            const SizedBox(width: 10),
            Text(_studentName ?? 'Carregando...'),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey,
            height: 1.0,
          ),
        ),
        actions: [
          // Barra azul para filtrar por disciplina
          GestureDetector(
            onTap: () {
              _showDisciplinaDropdown(context);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: const Color(0xFF007BFF), 
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Filtrar por disciplina',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Meus Portfólios',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Verificar se está carregando
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else
                  _portfolios.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _portfolios.length,
                          itemBuilder: (context, index) {
                            final portfolio = _portfolios[index];

                            // Conversão do Timestamp para DateTime
                            Timestamp timestamp = portfolio['dataCriacao'];
                            DateTime date = timestamp.toDate();

                            // Formatação da data
                            String formattedDate = DateFormat('dd/MM/yyyy').format(date);

                            return Card(
                              child: ListTile(
                                title: Text(portfolio['titulo'] ?? 'Sem título'),
                                subtitle: Text('Data de criação: $formattedDate'),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                            'Você ainda não possui portfólios',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDisciplinaDropdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione uma disciplina'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _disciplinas.map((disciplina) {
                return ListTile(
                  title: Text(disciplina['nome']),
                  onTap: () {
                    if (disciplina['id'] != _selectedDisciplina) {
                      setState(() {
                        _selectedDisciplina = disciplina['id'];
                        // Filtrar os portfólios quando a disciplina mudar
                        _filterPortfoliosByDisciplina(); 
                      });
                    }
                    Navigator.of(context).pop(); // Fecha o dialog
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); 
              },
            ),
          ],
        );
      },
    );
  }
}
