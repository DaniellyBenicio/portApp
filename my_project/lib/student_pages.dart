import 'package:flutter/material.dart';

// Student Portfolio Page
class StudentPortfolioPage extends StatelessWidget {
  const StudentPortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(
            left: 16.0,
            top: 16.0,
            right: 16.0,
            bottom: 16.0,
          ),
          child: const TextField(
            decoration: InputDecoration(
              labelText: 'Digite o nome da disciplina', // Texto do rótulo
              border: OutlineInputBorder(), // Borda ao redor da caixa de texto
              suffixIcon: Icon(
                Icons.search,
              ), // Ícone de pesquisa dentro da caixa de texto
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
            left: 16.0,
            top: 0.0,
            right: 16.0,
            bottom: 0.0,
          ),
          child: const Text(
            'Meus Portifólios - Amanda',
            textAlign: TextAlign.left, // Define o alinhamento do texto
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
            left: 16.0,
            top: 16.0,
            right: 16.0,
            bottom: 16.0,
          ),
          child: const Text(
            'Portifolios',
          ),
        ),
      ],
    );
  }
}


// Student Subjects Page
class StudentSubjectsPage extends StatelessWidget {
  const StudentSubjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Exemplo de disciplinas
    final List<String> subjects = [
      'Matemática',
      'Português',
      'História',
      'Geografia',
      'Ciências',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disciplinas'),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(subjects[index]),
            onTap: () {
              // Navegação para detalhes da disciplina
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubjectDetailsPage(subject: subjects[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Página de detalhes da disciplina
class SubjectDetailsPage extends StatelessWidget {
  final String subject;

  const SubjectDetailsPage({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subject),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              subject,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Descrição detalhada da disciplina aqui.',
              style: TextStyle(fontSize: 16),
            ),
            // Adicione mais widgets aqui para exibir detalhes adicionais
          ],
        ),
      ),
    );
  }
}

