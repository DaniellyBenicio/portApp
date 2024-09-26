import 'package:flutter/material.dart';
import '../../menu.dart';
import 'page_helpers.dart';

class HomePage extends StatefulWidget {
  final String userType; //Tipo de usuário

  const HomePage({super.key, required this.userType});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

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
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Notificações',
            color: Colors.white,
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
      body: getPages(widget.userType)[_currentIndex], //Exibe a página atual com base no índice
    );
  }
}