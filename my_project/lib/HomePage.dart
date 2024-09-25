import 'package:flutter/material.dart';
import 'package:my_project/iconsPortfolio.dart';
import 'menu.dart';
import 'student_pages.dart';
import 'teacher_pages.dart';
import 'settings_page.dart';
import 'disciplinesPage.dart'; 
import 'AlunoDisciplinesPage.dart';


//Página principal do aplicativo
class HomePage extends StatefulWidget {
  final String userType; //Tipo de usuário

  const HomePage({super.key, required this.userType});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  //Método que retorna as páginas com base no tipo de usuário
  List<Widget> _getPages() {
    if (widget.userType == 'Aluno') {
      return [
        const StudentPortfolioPage(),
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

//Método que atualiza o índice da página atual e navega para a nova página
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    //Navegação para páginas específicas com base no índice
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
      backgroundColor: const Color.fromRGBO(18, 86, 143, 1),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Voltar',
        onPressed: () {
          Navigator.pop(context);
        },
      ),
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
        currentIndex: _currentIndex, //Passa o índice atual para o Menu
        onItemTapped: _onItemTapped, //Callback para item selecionado
      ),
      body: _getPages()[_currentIndex], //Exibe a página atual com base no índice
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
