import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_project/services/portfolio_service.dart';

class PortfolioPage extends StatefulWidget {
  final String disciplinaId; 
  final String disciplinaNome;

  const PortfolioPage({Key? key, required this.disciplinaId, required this.disciplinaNome}) : super(key: key);

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final PortfolioService _portfolioService = PortfolioService(); 
  bool _isLoading = false;

  void _showAddPortfolioDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Portfólio'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um título';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira uma descrição';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : () async {
                if (_formKey.currentState!.validate()) {
                  await _addPortfolio();
                }
              },
              child: _isLoading 
                ? CircularProgressIndicator() 
                : const Text('Salvar'),
            ),
            TextButton(
              onPressed: () {
                _tituloController.clear(); 
                _descricaoController.clear(); 
                Navigator.of(context).pop(); 
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addPortfolio() async {
    setState(() {
      _isLoading = true; 
    });

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Verifica se a disciplina existe pelo ID
      DocumentSnapshot disciplinaSnapshot = await FirebaseFirestore.instance
          .collection('Disciplinas')
          .doc(widget.disciplinaId)
          .get();

      if (!disciplinaSnapshot.exists) {
        print('Disciplina não encontrada para o ID: ${widget.disciplinaId}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disciplina não encontrada.')),
        );
        setState(() {
          _isLoading = false; 
        });
        return;
      }

      try {
        await _portfolioService.adicionarPortfolio(
          disciplinaId: widget.disciplinaId,
          titulo: _tituloController.text,
          descricao: _descricaoController.text,
          professorUid: user.uid,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Portfólio adicionado com sucesso!')),
        );

        _tituloController.clear();
        _descricaoController.clear();
        Navigator.of(context).pop();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa estar logado para adicionar um portfólio.')),
      );
    }

    setState(() {
      _isLoading = false; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Portfólio - ${widget.disciplinaNome}'), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _showAddPortfolioDialog,
              child: const Text('Adicionar'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Disciplinas')
                    .doc(widget.disciplinaId)
                    .collection('Portfolios')
                    .orderBy('dataCriacao', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Nenhum portfólio encontrado.'));
                  }

                  final portfolios = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: portfolios.length,
                    itemBuilder: (context, index) {
                      final portfolio = portfolios[index].data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(portfolio['titulo']),
                          subtitle: Text(portfolio['descricao']),
                          trailing: Text(portfolio['dataCriacao']?.toDate().toString() ?? ''),
                        ),
                      );
                    },
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
