import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String userType;

  const HomePage({Key? key, required this.userType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Text(
          'Bem-vindo(a), $userType!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
