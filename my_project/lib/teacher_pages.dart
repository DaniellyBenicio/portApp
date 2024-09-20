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
        // Add more widgets as needed
      ],
    );
  }
}

// Teacher Subjects Page
class TeacherSubjectsPage extends StatelessWidget {
  const TeacherSubjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Teacher Subjects',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

