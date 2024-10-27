import 'package:flutter/material.dart';

class IconPortfolio extends StatelessWidget {
  final Function(int index) onTapPortfolio;

  IconPortfolio({required this.onTapPortfolio});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true, // Permite que o GridView use apenas o espaço necessário
        physics: const NeverScrollableScrollPhysics(), // Desativa a rolagem interna do GridView
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Duas colunas
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.0, // Proporção entre largura e altura dos itens
        ),
        itemCount: 6, // Número de itens no GridView
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Chama a função passada como argumento quando um portfólio é clicado
              onTapPortfolio(index);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://static8.depositphotos.com/1006076/953/v/450/depositphotos_9536683-stock-illustration-vector-still-life-subjects-of.jpg',
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Portfólio ${index + 1}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
