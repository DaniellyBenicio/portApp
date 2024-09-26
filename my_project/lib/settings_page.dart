import 'package:flutter/material.dart';
import 'seletor.dart'; 

class SettingsPage extends StatelessWidget {
  final String userType;

  const SettingsPage({super.key, required this.userType}); //Armazena o tipo de usuário

  //Método para exibir um diálogo de confirmação para logout
  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, //Impede que o usuário feche o diálogo ao tocar fora
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Saída'),
          content: const Text('Você realmente deseja sair da sua conta?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); //Fecha o diálogo
              },
            ),
            TextButton(
              child: const Text('Sair'),
              onPressed: () {
                Navigator.of(context).pop(); //Fecha o diálogo
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Seletor()),
                  (route) => false, //Remove todas as rotas anteriores
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
        title: const Text(
        'Configurações',
          style: TextStyle(
            color: Colors.black,
                fontFamily: 'Inter',
                fontSize: 26,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w600,
                height: 1.0,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const Row(
              children: <Widget>[
                Icon(Icons.person, size: 28), 
                SizedBox(width: 8),
                Text(
                  'Conta',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar Perfil'),
              onTap: () {
                Navigator.pushNamed(context, '/editProfile');//Navega para a tela de edição de perfil
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Trocar Senha'),
              onTap: () {
                Navigator.pushNamed(context, '/changePassword');//Navega para a tela de mudar senha
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text(
                'Excluir Conta',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/deleteAccount');//Navega para a tela de deletar conta
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info), 
              title: const Text('Sobre Nós'),
              onTap: () {
                Navigator.pushNamed(context, '/aboutUs');//Navega para a tela sobre nós
              },
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, 
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(120, 40),
                ),
                onPressed: () {
                  _showLogoutConfirmationDialog(context); //Mostra o diálogo de confirmação de logout
                },
                child: const Text('Sair'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
