import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PortfolioDetailPage extends StatelessWidget {
  final String portfolioId;

  const PortfolioDetailPage({super.key, required this.portfolioId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Portfólio'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('Portfolios') 
            .doc(portfolioId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os detalhes do portfólio.'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Portfólio não encontrado.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['titulo'] ?? 'Título não disponível',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  data['descricao'] ?? 'Descrição não disponível',
                  style: const TextStyle(fontSize: 16),
                ),
                // Adicione mais campos conforme necessário
              ],
            ),
          );
        },
      ),
    );
  }
}
