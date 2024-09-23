import 'package:flutter/material.dart';

// Teacher Portfolio Page
class TeacherPortfolioPage extends StatelessWidget {
  const TeacherPortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(16.0),
          child: const Text(
            'Teacher Portfolio',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}


//Ver quais arquivos ficaram aqui após deesenvolvimento do port