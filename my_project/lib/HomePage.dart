import 'package:flutter/material.dart';
import 'package:my_project/iconsPortfolio.dart';
import 'menu.dart';
// Importe o arquivo onde o Menu está definido

class HomePage extends StatefulWidget {
  final String userType;

  const HomePage({Key? key, required this.userType}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    PortfolioPage(),
    NotificationsPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navegação entre páginas
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/HomePage');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/notifications');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Notifications',
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
      body: _pages[_currentIndex],
    );
  }
}


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
