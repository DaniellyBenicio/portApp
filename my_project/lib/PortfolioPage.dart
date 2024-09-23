import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PortfolioPage extends StatefulWidget {
  final String disciplinaId;

  const PortfolioPage({super.key, required this.disciplinaId});//ID da disciplina associada ao portfólio

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  List<Map<String, dynamic>> portfolios = []; //Lista para armazenar portfólios
  String? usuarioUid; //UID do usuário atual
  bool isProfessor = false; //Verifica se o usuário é um professor

  @override
  void initState() {
    super.initState();
    _fetchPortfolios(); //Busca os portfólios na inicialização
    _getUsuarioUid(); //Obtém o UID do usuário
  }

  //Obtém o UID do usuário e verifica se é professor
  Future<void> _getUsuarioUid() async {
    final user = FirebaseAuth.instance.currentUser; //Obtém o usuário atual
    if (user != null) {
      setState(() {
        usuarioUid = user.uid; //Armazena o UID
      });

      //Verifica o tipo de usuário no Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(user.uid)
          .get();

      if (snapshot.exists && snapshot.data()?['tipoUsuario'] == 'professor') {
        setState(() {
          isProfessor = true; //Atualiza a variável se for professor
        });
      }
    }
  }

  //Método para buscar os portfólios da disciplina
  Future<void> _fetchPortfolios() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Disciplinas')
          .doc(widget.disciplinaId)
          .collection('Portfolios')
          .get();

      setState(() {
        portfolios = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'titulo': doc['titulo'],
            'descricao': doc['descricao'],
            'instrucoes': doc['instrucoes'],
            'sugestoes': doc['sugestoes'] ?? [],
            'professorUid': doc['professorUid'],
          };
        }).toList(); //Converte os documentos em uma lista de mapas
      });
    } catch (e) {
      print('Erro ao buscar portfólios: $e'); 
    }
  }

  //Método para adicionar um novo portfólio
  void _adicionarPortfolio() {
    //Controladores de texto para os campos do diálogo
    final TextEditingController tituloController = TextEditingController();
    final TextEditingController descricaoController = TextEditingController();
    final TextEditingController instrucoesController = TextEditingController();
    final TextEditingController sugestaoController = TextEditingController();

    //Exibe um diálogo para adicionar um portfólio
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Portfólio'),
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
                TextField(
                  controller: instrucoesController,
                  decoration: const InputDecoration(labelText: 'Instruções para os alunos'),
                  maxLines: 3,
                ),
                TextField(
                  controller: sugestaoController,
                  decoration: const InputDecoration(labelText: 'Sugestões de Tópicos'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); //Fecha o diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                //Valida se todos os campos estão preenchidos
                if (tituloController.text.isEmpty ||
                    descricaoController.text.isEmpty ||
                    instrucoesController.text.isEmpty ||
                    sugestaoController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Todos os campos são obrigatórios!')),
                  );
                  return; //Retorna se algum campo estiver vazio
                }

                //Cria um novo portfólio no Firestore
                final data = {
                  'titulo': tituloController.text,
                  'descricao': descricaoController.text,
                  'instrucoes': instrucoesController.text,
                  'sugestoes': [sugestaoController.text],
                  'professorUid': usuarioUid,
                };

                await FirebaseFirestore.instance
                    .collection('Disciplinas')
                    .doc(widget.disciplinaId)
                    .collection('Portfolios')
                    .add(data);

                Navigator.of(context).pop(); //Fecha o diálogo
                _fetchPortfolios(); //Atualiza a lista de portfólios
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfólios'), 
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: portfolios.map((portfolio) { //Mapeia os portfólios para widgets
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              title: Text(portfolio['titulo'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(portfolio['descricao']),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Instruções: ${portfolio['instrucoes'] ?? 'Sem instruções fornecidas'}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                if (portfolio['sugestoes'] != null && portfolio['sugestoes'].isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sugestões de Atividades:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...portfolio['sugestoes'].map<Widget>((sugestao) => Text('- $sugestao')).toList(),
                      ],
                    ),
                  ),
                if (!isProfessor) //Condicional para exibir o botão se não for professor
                  TextButton.icon(
                    onPressed: () {
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Atividade'),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
      floatingActionButton: isProfessor //Exibe o FAB se for professor
          ? FloatingActionButton(
              onPressed: _adicionarPortfolio, //Chama o método para adicionar portfólio
              tooltip: 'Adicionar Portfólio',
              child: const Icon(Icons.add),
            )
          : null, //Não exibe o FAB se não for professor
    );
  }
}