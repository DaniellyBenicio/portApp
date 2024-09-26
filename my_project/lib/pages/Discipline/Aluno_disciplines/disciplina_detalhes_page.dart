import 'package:flutter/material.dart';

class DisciplinaDetalhesPage extends StatelessWidget {
  final Map<String, dynamic> disciplina;

  const DisciplinaDetalhesPage({Key? key, required this.disciplina}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(disciplina['nome']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descrição: ${disciplina['descricao']}', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            // Outras informações da disciplina podem ser exibidas aqui.
          ],
        ),
      ),
    );
  }
}