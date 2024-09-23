import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Página principal para exibir as disciplinas do aluno
class AlunoDisciplinesPage extends StatefulWidget {
  @override
  _AlunoDisciplinesPageState createState() => _AlunoDisciplinesPageState();
}

class _AlunoDisciplinesPageState extends State<AlunoDisciplinesPage> {
  //Controladores para os campos de texto
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  
  //Lista para armazenar as disciplinas buscadas
  List<Map<String, dynamic>> disciplinas = [];
  bool loading = false; //Indica se está carregando os dados

  //Busca disciplinas pelo nome
  Future<void> _buscarDisciplinasPorNome() async {
    final nomeDisciplina = nomeController.text.trim();
    if (nomeDisciplina.isEmpty) {
      _showSnackBar('Por favor, insira um nome de disciplina');
      return;
    }

    setState(() {
      loading = true; //Inicia o carregamento
    });

    try {
      final user = FirebaseAuth.instance.currentUser; //Obtém o usuário autenticado
      if (user == null) {
        _showSnackBar('Usuário não autenticado');
        return;
      }

      //Busca disciplinas no Firestore com base no nome e no ID do professor
      final snapshot = await FirebaseFirestore.instance
          .collection('Disciplinas')
          .where('nome', isEqualTo: nomeDisciplina)
          .where('professorUid', isEqualTo: user.uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        disciplinas = snapshot.docs.map((doc) {
          return {
            'id': doc.id, //Adiciona o ID do documento
            ...doc.data() as Map<String, dynamic>, //Adiciona os dados da disciplina
          };
        }).toList();
        nomeController.clear(); //Limpa o campo após a busca
      } else {
        _showSnackBar('Disciplina não encontrada');
      }
    } catch (e) {
      print('Erro ao buscar disciplinas: $e');
      _showSnackBar('Erro ao buscar disciplinas');
    } finally {
      setState(() {
        loading = false; //Finaliza o carregamento
      });
    }
  }

  //Função para buscar disciplina pelo código de acesso
  Future<void> _buscarDisciplinaPorCodigo() async {
    final codigoAcesso = codigoController.text.trim();
    if (codigoAcesso.isEmpty) {
      _showSnackBar('Por favor, insira um código de acesso');
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackBar('Usuário não autenticado');
        return;
      }

      //Busca disciplina no Firestore pelo código de acesso
      final snapshot = await FirebaseFirestore.instance
          .collection('Disciplinas')
          .where('codigoAcesso', isEqualTo: codigoAcesso)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final disciplina = {
          'id': snapshot.docs.first.id,
          ...snapshot.docs.first.data() as Map<String, dynamic>,
        };

        //Navega para a página de detalhes da disciplina
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisciplinaDetalhesPage(disciplina: disciplina),
          ),
        );
        codigoController.clear(); 
      } else {
        _showSnackBar('Código de acesso inválido ou disciplina não encontrada');
      }
    } catch (e) {
      print('Erro ao buscar disciplina: $e');
      _showSnackBar('Erro ao buscar disciplina');
    }
  }

  //Função para exibir mensagens de erro
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Disciplinas')),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Busque por disciplina',
                      suffixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: loading ? null : _buscarDisciplinasPorNome,
                    child: loading ? const CircularProgressIndicator() : const Text('Buscar'),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: disciplinas.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(disciplinas[index]['nome']),
                            subtitle: Text(disciplinas[index]['descricao']),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DisciplinaDetalhesPage(disciplina: disciplinas[index]),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Entrar em uma disciplina pelo código
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Entrar em uma Disciplina pelo Código', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  //Campo para nserir o código de acesso
                  TextField(
                    controller: codigoController,
                    decoration: const InputDecoration(
                      labelText: 'Código de Acesso',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _buscarDisciplinaPorCodigo,
                    child: const Text('Entrar na Disciplina'),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: disciplinas.isEmpty
                          ? const Text('Você ainda não está matriculado em nenhuma disciplina.')
                          : Container(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Página para exibir detalhes da disciplina
class DisciplinaDetalhesPage extends StatelessWidget {
  final Map<String, dynamic> disciplina;

  const DisciplinaDetalhesPage({Key? key, required this.disciplina}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(disciplina['nome'])),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              disciplina['nome'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              disciplina['descricao'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
              },
              child: const Text('Ação Adicional'),
            ),
          ],
        ),
      ),
    );
  }
}
