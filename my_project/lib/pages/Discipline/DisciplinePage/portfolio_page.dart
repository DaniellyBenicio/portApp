import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_project/services/portfolio_service.dart';

class PortfolioPage extends StatefulWidget {
  final String disciplinaId;
  final String disciplinaNome;

  const PortfolioPage({
    Key? key,
    required this.disciplinaId,
    required this.disciplinaNome,
  }) : super(key: key);

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final PortfolioService _portfolioService = PortfolioService();
  bool _isLoading = false;

  List<String> _tiposArquivosSelecionados = [];
  bool _permitirComentario = true;
  bool _permitirMultipleFiles = false;

  final Map<String, List<String>> _tiposDeArquivos = {
    'Documentos de Texto': ['docx', 'pdf', 'txt', 'odt'],
    'Imagens': ['jpg', 'jpeg', 'png', 'gif', 'bmp'],
    'Vídeos': ['mp4', 'avi', 'mov', 'wmv'],
  };

  void _showPortfolioDialog({String? portfolioId, Map<String, dynamic>? data}) {
    _tituloController.text = data?['titulo'] ?? '';
    _descricaoController.text = data?['descricao'] ?? '';
    _permitirComentario = data?['permitirComentario'] ?? true;
    _permitirMultipleFiles = data?['permitirMultipleFiles'] ?? false;
    _tiposArquivosSelecionados =
        data?['tipoArquivo']?.cast<String>() ?? <String>[];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(portfolioId == null
                ? 'Adicionar Portfólio'
                : 'Editar Portfólio'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextFormField(
                      controller: _tituloController,
                      label: 'Título',
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Por favor, insira um título' : null,
                    ),
                    _buildTextFormField(
                      controller: _descricaoController,
                      label: 'Descrição',
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Por favor, insira uma descrição' : null,
                    ),
                    const Text('Tipos de Arquivo Permitidos'),
                    Column(
                      children: _tiposDeArquivos.keys.map((tipo) {
                        return CheckboxListTile(
                          title: Text(tipo),
                          value: _tiposArquivosSelecionados.contains(tipo),
                          onChanged: (bool? value) {
                            setDialogState(() {
                              if (value == true) {
                                _tiposArquivosSelecionados.add(tipo);
                              } else {
                                _tiposArquivosSelecionados.remove(tipo);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SwitchListTile(
                      title: const Text('Permitir Comentário'),
                      value: _permitirComentario,
                      onChanged: (value) {
                        setDialogState(() {
                          _permitirComentario = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Permitir Múltiplos Arquivos'),
                      value: _permitirMultipleFiles,
                      onChanged: (value) {
                        setDialogState(() {
                          _permitirMultipleFiles = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () => _savePortfolio(portfolioId: portfolioId),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Salvar'),
              ),
            ],
          );
        });
      },
    );
  }

  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: validator,
    );
  }

  Future<void> _savePortfolio({String? portfolioId}) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('Você precisa estar logado.');
      return;
    }

    try {
      if (_tiposArquivosSelecionados.isEmpty) {
        _showSnackBar('Por favor, selecione pelo menos um tipo de arquivo.');
        return;
      }

      await _portfolioService.salvarPortfolio(
        portfolioId: portfolioId,
        disciplinaId: widget.disciplinaId,
        titulo: _tituloController.text,
        descricao: _descricaoController.text,
        professorUid: user.uid,
        tipoArquivo: _tiposArquivosSelecionados,
        permitirComentario: _permitirComentario,
        permitirMultipleFiles: _permitirMultipleFiles,
      );

      _showSnackBar('Portfólio salvo com sucesso!');
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    } catch (error) {
      _showSnackBar('Erro ao salvar: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDeletePortfolio(String portfolioId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Você tem certeza de que deseja excluir este portfólio?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _deletePortfolio(portfolioId);
    }
  }

  Future<void> _deletePortfolio(String portfolioId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showSnackBar('Você precisa estar logado.');
      return;
    }

    try {
      await _portfolioService.excluirPortfolio(
        disciplinaId: widget.disciplinaId,
        portfolioId: portfolioId,
      );
      _showSnackBar('Portfólio excluído com sucesso!');
    } catch (error) {
      _showSnackBar('Erro ao excluir: $error');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
              onPressed: () => _showPortfolioDialog(),
              child: const Text('Adicionar Portfólio'),
            ),
            const SizedBox(height: 16),
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

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Nenhum portfólio encontrado.'));
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final portfolioId = doc.id;

                      return ListTile(
                        title: Text(data['titulo']),
                        subtitle: Text(data['descricao']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showPortfolioDialog(
                                  portfolioId: portfolioId,
                                  data: data,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _confirmDeletePortfolio(portfolioId),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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
