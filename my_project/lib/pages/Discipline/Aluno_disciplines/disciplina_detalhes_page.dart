import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DisciplinaDetalhesPage extends StatefulWidget {
  final Map<String, dynamic> disciplina;

  const DisciplinaDetalhesPage({Key? key, required this.disciplina}) : super(key: key);

  @override
  _DisciplinaDetalhesPageState createState() => _DisciplinaDetalhesPageState();
}

class _DisciplinaDetalhesPageState extends State<DisciplinaDetalhesPage> {
  List<Map<String, dynamic>> portfolios = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _recuperarPortfolios();
  }

  Future<void> _recuperarPortfolios() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorDialog('Usuário não autenticado');
      return;
    }

    try {
      // Verificar se o aluno está matriculado na disciplina
      final matriculaSnapshot = await FirebaseFirestore.instance
          .collection('Matriculas')
          .where('alunoUid', isEqualTo: user.uid)
          .where('disciplinaId', isEqualTo: widget.disciplina['id']) // Use a ID da disciplina
          .get();

      if (matriculaSnapshot.docs.isEmpty) {
        _showErrorDialog('Você não está matriculado nesta disciplina.');
        return;
      }

      // Recuperar portfólios da disciplina
      final snapshot = await FirebaseFirestore.instance
          .collection('Disciplinas') // Coleção de Disciplinas
          .doc(widget.disciplina['id']) // Documento da disciplina
          .collection('Portfolios') // Subcoleção de Portfólios
          .get();

      // Mapear os portfólios para uma lista
      portfolios = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      // Atualizar o estado e definir loading como false
      setState(() {
        loading = false; // Marcar como não carregando após a recuperação
      });
    } catch (e) {
      if (e is FirebaseException) {
        print('Erro ao recuperar portfólios: $e');
        _showErrorDialog('Erro ao recuperar portfólios: ${e.message}');
      } else {
        _showErrorDialog('Erro inesperado: $e');
      }
      // Garantir que loading seja atualizado mesmo em erro
      setState(() {
        loading = false; // Atualizar loading em caso de erro
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar o dialog
              },
              child: const Text('OK'),
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
        title: const Text('Meus Portfólios'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Portfólios:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: portfolios.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 4,
                          child: ListTile(
                            title: Text(
                              portfolios[index]['titulo'] ?? 'Sem título',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              portfolios[index]['descricao'] ?? 'Sem descrição',
                              style: const TextStyle(fontSize: 16),
                            ),
                            onTap: () {
                              // Navegar para a página de detalhes do portfólio
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PortfolioDetalhesPage(portfolio: portfolios[index]),
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
    );
  }
}

// Exemplo de página de detalhes do portfólio
class PortfolioDetalhesPage extends StatelessWidget {
  final Map<String, dynamic> portfolio;

  const PortfolioDetalhesPage({Key? key, required this.portfolio}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(portfolio['titulo'] ?? 'Detalhes do Portfólio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Título: ${portfolio['titulo']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Descrição: ${portfolio['descricao'] ?? 'Sem descrição'}',
              style: const TextStyle(fontSize: 16),
            ),
            // Adicione outros detalhes relevantes do portfólio aqui
          ],
        ),
      ),
    );
  }
}
