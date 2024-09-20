import 'package:flutter/material.dart';
import 'package:my_project/iconsPortfolio.dart';
import 'menu.dart';
import 'student_pages.dart';
import 'teacher_pages.dart';
import 'settings_page.dart';
import 'disciplinesPage.dart'; 


class HomePage extends StatefulWidget {
  final String userType; // aluno ou professor

  const HomePage({Key? key, required this.userType}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  List<Widget> _getPages() {
    if (widget.userType == 'Aluno') {
      return [
        StudentPortfolioPage(),
        DisciplinesPage(),
        SettingsPage(userType: widget.userType),
      ];
    } else if (widget.userType == 'Professor') {
      return [
        TeacherPortfolioPage(),
        DisciplinesPage(),
        SettingsPage(userType: widget.userType),
      ];
    } else {
      return [
        Center(child: Text('Tipo de usuário inválido')),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navegação entre páginas (use pushNamed para evitar substituição completa)
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/HomePage');
        break;
      case 1:
        Navigator.pushNamed(context, '/disciplinas');
        break;
      case 2:
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Garante apenas uma seta de voltar
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Notificações',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/notifications');
            },
          ),
        ],
      ),
      bottomNavigationBar: Menu(
        currentIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
      body: _getPages()[_currentIndex],
    );
  }
}
<<<<<<< HEAD


class PortfolioPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meus Portifólios',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Digite o nome da disciplina',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  // Adiciona o widget IconPortfolio com a função onTapPortfolio
                  for (int i = 0; i < 1; i++) // Substitua 6 pelo número desejado
                    IconPortfolio(
                      onTapPortfolio: (index) {
                        // Define o comportamento ao clicar em um portfólio
                        print('Portfólio ${index + 1} clicado');
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Notificações Page'));
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Configurações Page'));
  }
}
=======
>>>>>>> 9b64202829c591b70b66a6ae79629bfc4d4efd45
