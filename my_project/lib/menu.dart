import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  final int currentIndex;//Atributo que define qual item está atualmente selecionado no menu
  final ValueChanged<int> onItemTapped;//Função de callback que é acionada quando um item do menu é selecionado

  const Menu({ //indica que esses parâmetros são obrigatórios ao instanciar o Menu
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(

      currentIndex: currentIndex, //Define qual item do menu está atualmente selecionado
      onTap: onItemTapped, //Função chamada quando um item é tocado
      selectedItemColor: const Color.fromRGBO(19, 79, 145, 1), //Define a cor do item selecionado
      unselectedItemColor: const Color.fromRGBO(5, 4, 4, 0.5),
      iconSize: 30, //Tamanho dos ícones
      selectedFontSize: 14, //Tamanho da fonte do item selecionado
      unselectedFontSize: 12, //Tamanho da fonte dos itens não selecionados

      items: const <BottomNavigationBarItem>[//Itens que aparecerão no BottomNavigationBar
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
