import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre Nós'), //Título do AppBar
        centerTitle: true, //Centraliza o título
        backgroundColor: Colors.blue, //Define a cor de fundo 
        elevation: 4, //Define a sombra
      ),
      body: SingleChildScrollView( //Permite a rolagem do conteúdo 
        padding: const EdgeInsets.all(16.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, //Centraliza o conteúdo de forma horizontal
          children: <Widget>[
            //Título do Aplicativo
            const Align(
              alignment: Alignment.center, //Alinha o texto
              child: Text(
                'PortApp', 
                style: TextStyle(
                  fontSize: 28, //Define o tamanho da fonte
                  fontWeight: FontWeight.bold, //Define a fonte como negrito
                  color: Colors.blue, //Define a cor do texto
                ),
              ),
            ),
            const SizedBox(height: 10), 
            const Align(
              alignment: Alignment.center,
              child: Text(
                'PortApp é um aplicativo desenvolvido para o público da Educação de Jovens e Adultos - EJA.',
                style: TextStyle(
                  fontSize: 16, //Define o tamanho da fonte
                  color: Colors.black87, //Define a cor do texto
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20), 
            const Align(
              alignment: Alignment.center, 
              child: Text(
                'Nosso Objetivo', 
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.blue, 
                ),
              ),
            ),
            const SizedBox(height: 10), 
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Proporcionar uma plataforma simples e acessível para auxiliar na educação e organização dos alunos e professores.',
                style: TextStyle(
                  fontSize: 16, 
                  color: Colors.black87, 
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20), 
            const Align(
              alignment: Alignment.center, 
              child: Text(
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
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Para mais informações, entre em contato conosco através do e-mail:',
                style: TextStyle(
                  fontSize: 16, 
                  height: 1.5, 
                ),
              ),
            ),
            const SizedBox(height: 10), 
            const Align(
              alignment: Alignment.center, 
              child: Text(
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

  //Cria a lista de membros da equipe de desenvolvimento
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
              const SizedBox(width: 10), 
              Text(
                member, // Exibe o nome do membro da equipe.
                style: const TextStyle(fontSize: 16), 
              ),
            ],
          ),
        );
      }).toList(), // Converte a lista mapeada em uma lista de Widgets.
    );
  }
}