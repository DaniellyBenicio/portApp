import 'package:flutter/material.dart';
import '../../iconsPortfolio.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meus Portfólios',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(16.0),
            child: const TextField(
              decoration: InputDecoration(
                labelText: 'Digite o nome da disciplina',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < 1; i++) 
                    IconPortfolio(
                      onTapPortfolio: (index) {
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}