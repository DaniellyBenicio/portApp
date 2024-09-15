import 'package:flutter/material.dart';
import 'menu.dart';
import 'student_pages.dart';
import 'teacher_pages.dart';
import 'settings_page.dart';


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
        StudentSubjectsPage(),
        SettingsPage(userType: widget.userType),
      ];
    } else if (widget.userType == 'Professor') {
      return [
        TeacherPortfolioPage(),
        TeacherSubjectsPage(),
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
        automaticallyImplyLeading: true, // Garante apenas uma seta de voltar
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
