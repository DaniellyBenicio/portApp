import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre Nós'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // App Title
            Align(
              alignment: Alignment.center,
              child: const Text(
                'PortApp',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: const Text(
                'PortApp é um aplicativo desenvolvido para o público da Educação de Jovens e Adultos - EJA.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: const Text(
                'Nosso Objetivo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: const Text(
                'Proporcionar uma plataforma simples e acessível para auxiliar na educação e organização dos alunos e professores.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: const Text(
                'Equipe de Desenvolvimento:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildTeamMembers(),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: const Text(
                'Para mais informações, entre em contato conosco através do e-mail:',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: const Text(
                'contato@portapp.com',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMembers() {
    final teamMembers = [
      'José Olinda',
      'Danielly Benício',
      'Daniel Teixeira',
      'Amanda Souza',
      'Luan'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: teamMembers.map((member) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person, color: Colors.blue, size: 20),
              SizedBox(width: 10),
              Text(
                member,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
