import 'package:flutter/material.dart';
import 'seletor.dart'; // Certifique-se de importar a classe Seletor

class SettingsPage extends StatelessWidget {
  final String userType;

  SettingsPage({required this.userType});

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Impede o usuário de fechar o diálogo tocando fora dele
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Saída'),
          content: Text('Você realmente deseja sair da sua conta?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
            ),
            TextButton(
              child: Text('Sair'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Seletor()),
                  (route) => false, // Remove todas as rotas anteriores
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const Row(
              children: <Widget>[
                Icon(Icons.person, size: 28), // Mini ícone de conta
                SizedBox(width: 8), // Espaço entre o ícone e o texto
                Text(
                  'Conta',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text('Editar Perfil'),
              onTap: () {
                Navigator.pushNamed(context, '/editProfile');
              },
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Trocar Senha'),
              onTap: () {
                Navigator.pushNamed(context, '/changePassword');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text(
                'Excluir Conta',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/deleteAccount');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info), // Ícone para informações
              title: Text('Sobre Nós'),
              onTap: () {
                Navigator.pushNamed(context, '/aboutUs');
              },
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Botão em azul
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size(120, 40),
                ),
                onPressed: () {
                  _showLogoutConfirmationDialog(context); // Exibe a confirmação de logout
                },
                child: Text('Sair'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
