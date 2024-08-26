import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_project/services/firestore_service.dart'; // Corrija o caminho para o seu serviço Firestore

class Register extends StatefulWidget {
  final String userType;

  const Register({Key? key, required this.userType}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  Future<void> _register() async {
    if (_passwordController.text == _confirmPasswordController.text) {
      try {
        // Crie o usuário com FirebaseAuth
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Defina o ID do usuário
        final uid = userCredential.user?.uid;

        if (uid != null) {
          // Adiciona o usuário usando FirestoreService
          await FirestoreService().addUser(
            _emailController.text,
            _nameController.text,
            widget.userType,
            _additionalInfoController.text, // Ano de ingresso ou formação
          );

          // Mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registro realizado com sucesso!')),
          );

          Navigator.pop(context); // Navega de volta após o registro
        }
      } catch (e) {
        // Mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('As senhas não coincidem')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nome Completo'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Senha'),
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirmar Senha'),
            ),
            TextField(
              controller: _additionalInfoController,
              decoration: InputDecoration(
                labelText: widget.userType == 'aluno' ? 'Ano de Ingresso' : 'Formação',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
