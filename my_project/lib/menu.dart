import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const Menu({
    Key? key,
    required this.currentIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(

      currentIndex: currentIndex,
      onTap: onItemTapped,
      selectedItemColor: Color.fromRGBO(19, 79, 145, 1), // Define a cor do item selecionado
      unselectedItemColor: Color.fromRGBO(5, 4, 4, 0.5),
      iconSize: 30, // Tamanho dos ícones
      selectedFontSize: 14, // Tamanho da fonte do item selecionado
      unselectedFontSize: 12, // Tamanho da fonte dos itens não selecionados

      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.description),
          label: 'Portifólios',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.vrpano),
          label: 'Disciplinas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Configurações',
        ),
      ],
    );
  }
}
