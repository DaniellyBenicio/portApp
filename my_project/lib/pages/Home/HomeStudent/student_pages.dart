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
  bool _isLoading = true;
  List<Map<String, dynamic>> _portfolios = [];
  List<Map<String, dynamic>> _disciplinas = [];
  String? _selectedDisciplina;
  String? _errorMessage;

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

        await _fetchStudentName();
        await _fetchStudentDisciplinas(alunoUid);
        await _fetchPortfolios(alunoUid);
      }
    } catch (e) {
      print("Erro ao buscar dados do estudante: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

          if (mounted) {
            setState(() {
              _studentName = fullName;
              profileImageUrl = userData['profileImageUrl'] ?? '';
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _studentName = 'Aluno';
            });
          }
        }
      }
    } catch (e) {
      //
    }
  }

  Future<void> _fetchStudentDisciplinas(String alunoUid) async {
    try {
      final matriculasSnapshot = await FirebaseFirestore.instance
          .collection('Matriculas')
          .where('alunoUid', isEqualTo: alunoUid)
          .get();

      List<String> disciplinaIds = matriculasSnapshot.docs.map((doc) => doc['disciplinaId'] as String).toList();

      List<Map<String, dynamic>> disciplinas = [];
      for (String disciplinaId in disciplinaIds) {
        var disciplinaDoc = await FirebaseFirestore.instance.collection('Disciplinas').doc(disciplinaId).get();
        if (disciplinaDoc.exists) {
          disciplinas.add({
            'id': disciplinaId,
            'nome': disciplinaDoc['nome']
          });

          // Adiciona o aluno aos portfólios desta disciplina
          await _firestoreService.adicionarAlunoAosPortfolios(disciplinaId, alunoUid);
        }
      }

      setState(() {
        _disciplinas = disciplinas;
      });
    } catch (e) {
      print("Erro ao buscar disciplinas: $e");
    }
  }

  Future<void> _fetchPortfolios(String alunoUid) async {
    try {
      _portfolios = await _portfolioService.getPortfolios(
        _selectedDisciplina,
        alunoUid
      );
      
      setState(() {}); 
    } catch (e) {
      setState(() {
        _errorMessage = "Não foi possível carregar os portfólios. Tente novamente.";
      });
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
            Flexible(
              child: Text(
                _studentName ?? 'Carregando...',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18), // Adjust the font size here
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Colors.grey),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              _showDisciplinaDropdown(context);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: const Color(0xFF007BFF),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_errorMessage != null)
                  Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                else if (_portfolios.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _portfolios.length,
                    itemBuilder: (context, index) {
                      final portfolio = _portfolios[index];
                      return Card(
                        child: ListTile(
                          title: Text(portfolio['titulo']),
                          subtitle: Text(DateFormat('dd/MM/yyyy').format(portfolio['dataCriacao'].toDate())),
                          onTap: () {
                            // Navegação para a página de detalhes do portfólio
                          },
                        ),
                      );
                    },
                  )
                else
                  const Center(child: Text('Nenhum portfólio encontrado.')),
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
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecione uma Disciplina'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: _disciplinas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_disciplinas[index]['nome']),
                  onTap: () {
                    setState(() {
                      _selectedDisciplina = _disciplinas[index]['id']; // Seleciona a disciplina
                    });
                    // Recarrega os portfólios da disciplina selecionada
                    _fetchPortfolios(FirebaseAuth.instance.currentUser!.uid);
                    Navigator.pop(context); // Fecha o diálogo
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}
