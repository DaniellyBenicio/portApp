import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DisciplinePortPage extends StatefulWidget {
  final String disciplinaId;

  DisciplinePortPage({required this.disciplinaId});

  @override
  _DisciplinePortPageState createState() => _DisciplinePortPageState();
}

class _DisciplinePortPageState extends State<DisciplinePortPage> {
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
      // Primeiro, verifique se o aluno está matriculado na disciplina
      final matriculaSnapshot = await FirebaseFirestore.instance
          .collection('Matriculas')
          .where('alunoUid', isEqualTo: user.uid)
          .where('disciplinaId', isEqualTo: widget.disciplinaId) // Presumindo que você tenha a disciplinaId
          .get();

      if (matriculaSnapshot.docs.isEmpty) {
        _showErrorDialog('Você não está matriculado nesta disciplina.');
        return;
      }

      // Recuperar portfólios da disciplina
      final snapshot = await FirebaseFirestore.instance
          .collection('Disciplinas') // Acessar a coleção de Disciplinas
          .doc(widget.disciplinaId) // Acessar o documento da disciplina
          .collection('Portfolios') // Acessar a subcoleção de Portfólios
          .get();

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
        // Exibir mensagem de erro apropriada
        print('Erro ao recuperar portfólios: $e');
        _showErrorDialog('Erro ao recuperar portfólios: ${e.message}');
      } else {
        _showErrorDialog('Erro inesperado: $e');
      }
      // Definir loading como false em caso de erro
      setState(() {
        loading = false; // Garantir que loading seja atualizado mesmo em erro
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
        title: const Text('Portfólios da Disciplina'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : portfolios.isNotEmpty
              ? ListView.builder(
                  itemCount: portfolios.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        title: Text(portfolios[index]['titulo']),
                        subtitle: Text(portfolios[index]['descricao']),
                        onTap: () {
                          // Aqui você pode implementar a navegação para os detalhes do portfólio, se necessário
                        },
                      ),
                    );
                  },
                )
              : const Center(child: Text('Nenhum portfólio encontrado para esta disciplina.')),
    );
  }
}
