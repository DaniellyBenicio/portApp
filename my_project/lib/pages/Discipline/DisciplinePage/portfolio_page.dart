import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PortfolioPage extends StatefulWidget {
  final String disciplinaId; // Espera-se que seja o ID da disciplina

  const PortfolioPage({Key? key, required this.disciplinaId}) : super(key: key);

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

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
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await _addPortfolio();
                }
              },
              child: const Text('Salvar'),
            ),
            TextButton(
              onPressed: () {
                _tituloController.clear(); // Limpa os campos
                _descricaoController.clear(); // Limpa os campos
                Navigator.of(context).pop(); // Fecha o diálogo sem salvar
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addPortfolio() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Verifica se a disciplina existe pelo ID
      DocumentSnapshot disciplinaSnapshot = await FirebaseFirestore.instance
          .collection('Disciplinas')
          .doc(widget.disciplinaId) // Busca diretamente pelo ID da disciplina
          .get();

      if (!disciplinaSnapshot.exists) {
        print('Disciplina não encontrada para o ID: ${widget.disciplinaId}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disciplina não encontrada.')),
        );
        return;
      }

      // Referência para o Firestore
      final portfolioRef = FirebaseFirestore.instance
          .collection('Disciplinas')
          .doc(widget.disciplinaId) // ID da disciplina encontrado
          .collection('Portfolios')
          .doc(); // Gera um novo ID automaticamente

      // Salvar no Firestore
      try {
        await portfolioRef.set({
          'titulo': _tituloController.text,
          'descricao': _descricaoController.text,
          'professorUid': user.uid, // UID do professor
          'disciplinaId': widget.disciplinaId, // ID da disciplina
          'dataCriacao': FieldValue.serverTimestamp(),
        });

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Portfólio - ${widget.disciplinaId}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _showAddPortfolioDialog,
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }
}
