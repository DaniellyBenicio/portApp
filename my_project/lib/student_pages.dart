import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_project/services/firestore_service.dart';

class StudentPortfolioPage extends StatefulWidget {
  const StudentPortfolioPage({super.key});

  @override
  _StudentPortfolioPageState createState() => _StudentPortfolioPageState();
}

class _StudentPortfolioPageState extends State<StudentPortfolioPage> {
  final FirestoreService _firestoreService = FirestoreService();
  String? _studentName;
  String? profileImageUrl = 'https://example.com/default-profile.png'; // URL da imagem de perfil padrão
  bool _isLoading = true; // Variável para controle de loading
  String? selectedDiscipline;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchStudentName();
  }

  Future<void> _fetchStudentName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email ?? "";
        Map<String, String>? userData = await _firestoreService.getNomeAndImageByEmail(email);
        if (userData != null) {
          String firstName = userData['nome']?.split(' ')[0] ?? 'Estudante';
          setState(() {
            _studentName = firstName;
            profileImageUrl = userData['profileImageUrl'] ?? profileImageUrl;
            _isLoading = false; // Dados carregados
          });
        } else {
          setState(() {
            _isLoading = false; // Dados carregados, mas sem informações
          });
        }
      }
    } catch (e) {
      // Tratar erros de forma apropriada (ex.: exibir uma mensagem)
      setState(() {
        _isLoading = false; // Encerrar o loading mesmo em caso de erro
      });
      print('Erro ao buscar dados do aluno: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(profileImageUrl!),
            ),
            const SizedBox(width: 10),
            Text(_studentName ?? 'Carregando...'),
          ],
        ),
      ),
      body: Padding(
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
            // Filtros
            Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(18, 86, 143, 1),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: const Text(
                'Filtrar por',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildFilterRow(),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(18, 86, 143, 1),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: const Text(
                'Portfólios',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading) // Exibir loading enquanto busca os dados
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              const Center(
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
      ),
    );
  }

  Widget _buildFilterRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seção de disciplina
        Column(
          children: [
            Row(
              children: [
                const Icon(Icons.book, color: Colors.black),
                const SizedBox(width: 10),
                const Text(
                  'Disciplina:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    // Abre o dropdown ao clicar no botão
                    _showDisciplineDropdown();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(selectedDiscipline ?? 'Selecionar disciplina'),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Opções de disciplinas (inicialmente ocultas)
            if (selectedDiscipline != null)
              Column(
                children: ['Matemática', 'Português', 'Ciências']
                    .map((discipline) => GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDiscipline = discipline;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Text(discipline),
                          ),
                        ))
                    .toList(),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // Seção de data
        Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.black),
            const SizedBox(width: 8),
            const Text(
              'Data:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 60),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 33),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(selectedDate != null
                        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                        : 'Selecionar data'),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDisciplineDropdown() {
    setState(() {
      // Inicia a seleção da disciplina
      selectedDiscipline = null; // Reseta a seleção ao abrir
    });
  }
}
