import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:logger/logger.dart';


class ActivitiesPage extends StatefulWidget {
  final String disciplinaId;

  const ActivitiesPage({super.key, required this.disciplinaId});

  @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  List<Map<String, dynamic>> atividades = [];
  List<Map<String, dynamic>> portifolios = [];
  String? usuarioUid;
  String tipoArquivoSelecionado = 'PDF'; // Tipo de arquivo padrão
  bool isPortfolio = false; // Variável para controlar o checkbox

  @override
  void initState() {
    super.initState();
    _fetchAtividades();
    _fetchPortifolios();
    _getUsuarioUid();
  }

  Future<void> _getUsuarioUid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        usuarioUid = user.uid;
      });
    }
  }

  Future<void> _fetchAtividades() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Disciplinas')
          .doc(widget.disciplinaId)
          .collection('Atividades')
          .get();

      setState(() {
        atividades = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'titulo': doc['titulo'],
            'descricao': doc['descricao'],
            'tipoArquivo': doc['tipoArquivo'],
            'professorUid': doc['professorUid'],
          };
        }).toList();
      });
    } catch (e) {
      
      print('Erro ao buscar atividades: $e');
    }
  }

  Future<void> _fetchPortifolios() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Disciplinas')
          .doc(widget.disciplinaId)
          .collection('Portfolios')
          .get();

      setState(() {
        portifolios = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'titulo': doc['titulo'],
            'descricao': doc['descricao'],
            'tipoArquivo': doc['tipoArquivo'],
            'professorUid': doc['professorUid'],
          };
        }).toList();
      });
    } catch (e) {
      print('Erro ao buscar portfólios: $e');
    }
  }

  void _adicionarAtividadeOuPortfolio() {
    final TextEditingController tituloController = TextEditingController();
    final TextEditingController descricaoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Atividade/Portfólio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tituloController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: descricaoController,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                ),
                DropdownButton<String>(
                  value: tipoArquivoSelecionado,
                  onChanged: (String? newValue) {
                    setState(() {
                      tipoArquivoSelecionado = newValue!;
                    });
                  },
                  items: <String>[
                    'PDF', 'JPEG/JPG', 'PNG', 'GIF', 'SVG', 
                    'BMP', 'TIFF', 'RAW', 'MP4', 'AVI', 
                    'MKV', 'MOV', 'WMV', 'TXT', 'DOC', 
                    'DOCX', 'ODT', 'RTF', 'XLS', 'XLSX', 
                    'PPT', 'PPTX', 'ZIP', 'RAR', 'EXE', 
                    'JSON'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                CheckboxListTile(
                  title: const Text('Adicionar ao Portfólio'),
                  value: isPortfolio,
                  onChanged: (bool? value) {
                    setState(() {
                      isPortfolio = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (tituloController.text.isEmpty || descricaoController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: const Text('Título e descrição são obrigatórios!')),
                  );
                  return;
                }

                final data = {
                  'titulo': tituloController.text,
                  'descricao': descricaoController.text,
                  'tipoArquivo': tipoArquivoSelecionado,
                  'professorUid': usuarioUid,
                };

                if (isPortfolio) {
                  await FirebaseFirestore.instance
                      .collection('Disciplinas')
                      .doc(widget.disciplinaId)
                      .collection('Portfolios')
                      .add(data);
                } else {
                  await FirebaseFirestore.instance
                      .collection('Disciplinas')
                      .doc(widget.disciplinaId)
                      .collection('Atividades')
                      .add(data);
                }

                Navigator.of(context).pop();
                _fetchAtividades();
                _fetchPortifolios();
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void _deletarAtividade(String atividadeId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Disciplinas')
          .doc(widget.disciplinaId)
          .collection('Atividades')
          .doc(atividadeId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Atividade deletada com sucesso!')),
      );
      _fetchAtividades();
    } catch (e) {
      print('Erro ao deletar atividade: $e');
    }
  }

  void _deletarPortifolio(String portfolioId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Disciplinas')
          .doc(widget.disciplinaId)
          .collection('Portfolios')
          .doc(portfolioId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Portfólio deletado com sucesso!')),
      );
      _fetchPortifolios();
    } catch (e) {
      print('Erro ao deletar portfólio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atividades e Portfólios'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Exibir atividades
            ...atividades.map((atividade) {
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(atividade['titulo'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(atividade['descricao']),
                  tileColor: Colors.blue[50],
                ),
              );
            }).toList(),
            // Exibir portfólios
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Portfólios:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            ...portifolios.map((portfolio) {
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(portfolio['titulo'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(portfolio['descricao']),
                  tileColor: Colors.green[50],
                ),
              );
            }).toList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarAtividadeOuPortfolio,
        tooltip: 'Adicionar Atividade/Portfólio',
        child: const Icon(Icons.add),
      ),
    );
  }
}
