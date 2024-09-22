import 'package:flutter/material.dart';
import 'package:my_project/iconsPortfolio.dart';
import 'menu.dart';
import 'student_pages.dart';
import 'teacher_pages.dart';
import 'settings_page.dart';
import 'disciplinesPage.dart'; 
import 'AlunoDisciplinesPage.dart';


class HomePage extends StatefulWidget {
  final String userType; // aluno ou professor

  const HomePage({super.key, required this.userType});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  List<Widget> _getPages() {
    if (widget.userType == 'Aluno') {
      return [
        StudentPortfolioPage(),
        AlunoDisciplinesPage(),
        SettingsPage(userType: widget.userType),
      ];
    } else if (widget.userType == 'Professor') {
      return [
        const TeacherPortfolioPage(),
        DisciplinesPage(),
        SettingsPage(userType: widget.userType),
      ];
    } else {
      return [
        const Center(child: Text('Tipo de usuário inválido')),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

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
        automaticallyImplyLeading: false, 
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

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
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
            child: const TextField(
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
                  for (int i = 0; i < 1; i++) // Substitua 6 pelo número desejado
                    IconPortfolio(
                      onTapPortfolio: (index) {
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
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Notificações Page'));
  }
}
