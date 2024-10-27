import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_project/pages/Home/HomeTeacher/portfolioDetailPage.dart';
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
  bool _isLoading = true;
  List<Map<String, dynamic>> _disciplinas = [];

  @override
  void initState() {
    super.initState();
    _fetchTeacherData();
    _fetchDisciplinas();
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
          String firstName = nameParts.length >= 2 ? '${nameParts[0]} ${nameParts[1]}' : nameParts[0];

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
      String? professorUid = FirebaseAuth.instance.currentUser?.uid;
      List<Map<String, dynamic>> disciplinas = await _firestoreService.getDisciplinasPorProfessor(professorUid!);

      for (var disciplina in disciplinas) {
        List<Map<String, dynamic>> portfolios = await _firestoreService.getPortfoliosPorDisciplina(disciplina['id']);
        disciplina['portfolios'] = portfolios;
      }

      setState(() {
        _disciplinas = disciplinas;
      });
    } catch (e) {
      print('Erro ao buscar disciplinas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CustomAvatar(
              profileImageUrl: profileImageUrl,
              teacherName: _teacherName,
            ),
            const SizedBox(width: 10),
            Text(
              _teacherName ?? 'Carregando...',
              style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Divider(color: Colors.grey),
                    const Text(
                      'Portfólios',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_disciplinas.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _disciplinas.length,
                        itemBuilder: (context, index) {
                          final disciplina = _disciplinas[index];
                          List<Map<String, dynamic>> portfolios = disciplina['portfolios'];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 4,
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    disciplina['nome'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(color: Colors.grey),
                                  if (portfolios.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'Nenhum portfólio cadastrado.',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                      ),
                                    )
                                  else
                                    ...portfolios.map((portfolio) {
                                      return GestureDetector(
                                        onTap: () {
                                          if (portfolio['id'] != null) {
                                            String portfolioId = portfolio['id'].toString();
                                            print('Navigating to PortfolioDetailPage with ID: $portfolioId');
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PortfolioDetailPage(portfolioId: portfolioId),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('ID do portfólio não disponível.')),
                                            );
                                          }
                                        },
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.arrow_forward, color: Colors.grey[700]),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    portfolio['titulo'] ?? 'Nome do portfólio não disponível',
                                                    style: TextStyle(color: Colors.grey[700], fontSize: 16),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}