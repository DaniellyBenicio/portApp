/* portfolio_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/portfolio_service.dart'; 

class PortfolioPage extends StatefulWidget {
  final String disciplinaId;

  const PortfolioPage({super.key, required this.disciplinaId});

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  List<Map<String, dynamic>> portfolios = [];
  String? usuarioUid;
  bool isProfessor = false;
  DocumentSnapshot? lastDocument; // Para a paginação
  bool isLoading = false; // Indicador de carregamento

  @override
  void initState() {
    super.initState();
    _getUsuarioUid();
    _fetchPortfolios();
  }

  Future<void> _getUsuarioUid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        usuarioUid = user.uid;
      });

      final snapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(user.uid)
          .get();

      if (snapshot.exists && snapshot.data()?['tipoUsuario'] == 'professor') {
        setState(() {
          isProfessor = true;
        });
      }
    }
  }

  Future<void> _fetchPortfolios() async {
    if (isLoading) return; // Evita múltiplas chamadas simultâneas
    setState(() {
      isLoading = true;
    });

    try {
      final portfoliosData = await PortfolioService().getPortfolios(
          widget.disciplinaId, lastDocument); // Chame o método correto do serviço
      setState(() {
        portfolios.addAll(portfoliosData);
        lastDocument = portfoliosData.isNotEmpty ? portfoliosData.last['id'] : null; // Atualiza o lastDocument
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar portfólios: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _adicionarPortfolio() {
    final TextEditingController tituloController = TextEditingController();
    final TextEditingController descricaoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Portfólio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: tituloController, decoration: const InputDecoration(labelText: 'Título')),
                TextField(controller: descricaoController, decoration: const InputDecoration(labelText: 'Descrição')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                if (tituloController.text.isEmpty || descricaoController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Todos os campos são obrigatórios!')));
                  return;
                }

                try {
                  await PortfolioService().adicionarPortfolio(
                    disciplinaId: widget.disciplinaId,
                    titulo: tituloController.text,
                    descricao: descricaoController.text,
                    professorUid: usuarioUid!,
                  );
                  Navigator.of(context).pop();
                  _fetchPortfolios(); // Atualiza a lista de portfólios
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao adicionar portfólio: $e')));
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _detalhesPortfolio(String portfolioId) async {
    // Obtenha os detalhes de um portfólio específico
    try {
      final portfolioDetails = await PortfolioService().getPortfolioDetails(widget.disciplinaId, portfolioId);
      // Exiba os detalhes em um diálogo ou nova página
      if (portfolioDetails != null) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(portfolioDetails['titulo']),
              content: Text(portfolioDetails['descricao']),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fechar')),
              ],
            );
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao obter detalhes do portfólio: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portfólios'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: portfolios.map((portfolio) {
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(portfolio['titulo'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(portfolio['descricao']),
                    onTap: () => _detalhesPortfolio(portfolio['id']), // Ao tocar, mostra os detalhes
                  ),
                );
              }).toList(),
            ),
          ),
          if (isLoading) const CircularProgressIndicator(), // Indicador de carregamento
          if (!isLoading) TextButton(onPressed: _fetchPortfolios, child: const Text('Carregar mais')) // Botão para carregar mais
        ],
      ),
      floatingActionButton: isProfessor
          ? FloatingActionButton(onPressed: _adicionarPortfolio, tooltip: 'Adicionar Portfólio', child: const Icon(Icons.add))
          : null,
    );
  }
}

*/