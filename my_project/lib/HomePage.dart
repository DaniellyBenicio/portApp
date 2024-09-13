import 'package:flutter/material.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      // Alinha os widgets à esquerda
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
            left: 16.0,
            top: 16.0,
            right: 16.0,
            bottom: 16.0,
    ),

          child: TextField(
            decoration: InputDecoration(
              labelText: 'Digite o nome da disciplina', // Texto do rótulo
              border: OutlineInputBorder(), // Borda ao redor da caixa de texto
              suffixIcon: Icon(
                  Icons.search), // Ícone de pesquisa dentro da caixa de texto
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            left: 16.0,
            top: 0.0,
            right: 16.0,
            bottom: 0.0,
          ),
          child: Text(
            'Meus Portifólios - Amanda',
            textAlign: TextAlign.left, // Define o alinhamento do texto
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            left: 16.0,
            top: 16.0,
            right: 16.0,
            bottom: 16.0,
          ),
          child: Text(
            'Protifolios'
          ),
        ),
      ],
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
