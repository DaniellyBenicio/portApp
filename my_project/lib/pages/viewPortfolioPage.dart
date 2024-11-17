import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';


class ViewPortfolioPage extends StatefulWidget {
  final String portfolioId; 

  const ViewPortfolioPage({super.key, required this.portfolioId});

  @override
  _ViewPortfolioPageState createState() => _ViewPortfolioPageState();
}

class _ViewPortfolioPageState extends State<ViewPortfolioPage> {
  late Map<String, dynamic> _portfolio = {};
  bool _isLoading = false;
  File? _selectedFile;
  TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  // Função para carregar os dados do portfólio
  Future<void> _loadPortfolio() async {
    try {
      DocumentSnapshot portfolioSnapshot = await FirebaseFirestore.instance
          .collection('Portfolios')
          .doc(widget.portfolioId)
          .get();

      setState(() {
        _portfolio = portfolioSnapshot.data() as Map<String, dynamic>;
      });
    } catch (e) {
      // Tratar erro ao buscar o portfólio
      print("Erro ao carregar portfólio: $e");
    }
  }

  // Função para escolher e subir o arquivo
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  // Função para enviar o arquivo para o Firebase Storage
  Future<void> _uploadFile() async {
    if (_selectedFile != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Define o caminho do arquivo no Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child(
            'portfolio-files/${_portfolio['id']}/${_selectedFile!.path.split('/').last}');

        // Faz o upload do arquivo
        await storageRef.putFile(_selectedFile!);

        // Obtém a URL do arquivo após o upload
        String fileUrl = await storageRef.getDownloadURL();

        // Atualiza o Firestore com o link do arquivo
        await FirebaseFirestore.instance.collection('Portfolios').doc(_portfolio['id']).update({
          'arquivos': FieldValue.arrayUnion([fileUrl]),
        });

        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print("Erro ao fazer upload: $e");
      }
    }
  }

  // Função para enviar comentário, se permitido
  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      try {
        // Atualiza os comentários no Firestore
        await FirebaseFirestore.instance.collection('Portfolios').doc(_portfolio['id']).update({
          'comentarios': FieldValue.arrayUnion([_commentController.text]),
        });

        _commentController.clear();
      } catch (e) {
        print("Erro ao adicionar comentário: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_portfolio.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Portfólio")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_portfolio['titulo']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descrição: ${_portfolio['descricao']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Criado em: ${_portfolio['dataCriacao'].toDate()}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            // Se permitir envio de múltiplos arquivos
            if (_portfolio['permitirMultipleFiles'] == true)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enviar Arquivos:'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: const Text('Escolher Arquivo'),
                  ),
                  const SizedBox(height: 20),
                  if (_selectedFile != null)
                    Text('Arquivo Selecionado: ${_selectedFile!.path}'),
                  if (_isLoading) const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _uploadFile,
                    child: const Text('Enviar Arquivo'),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            // Se permitir comentários
            if (_portfolio['permitirComentario'] == true)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Adicionar Comentário:'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(hintText: 'Escreva seu comentário'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addComment,
                    child: const Text('Adicionar Comentário'),
                  ),
                ],
              ),
            // Exibe os comentários, se existirem
            if (_portfolio['comentarios'] != null && _portfolio['comentarios'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text('Comentários:'),
                  const SizedBox(height: 10),
                  ..._portfolio['comentarios'].map<Widget>((comment) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Text(
                        comment,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    );
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
