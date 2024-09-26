import 'package:flutter/material.dart';

class PortfolioPage extends StatelessWidget {
  final String disciplinaId;

  const PortfolioPage({Key? key, required this.disciplinaId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Portfolio - $disciplinaId'),
      ),
      body: Center(
        child: Text('Conteúdo do Portfolio para a disciplina $disciplinaId'),
      ),
    );
  }
}