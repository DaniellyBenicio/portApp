import 'package:flutter/material.dart';

import 'package:flutter/gestures.dart';

import 'Register.dart';
import 'RecoverPassword.dart'; 

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Ação do botão de voltar
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Centraliza os textos
            Text(
              'Entre com E-mail',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Insira sua conta de e-mail para enviar o código de verificação e faça login no PortApp.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            
            // Campos de Email e Senha alinhados à esquerda
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Senha',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RecoverPassword()),
                  );
                },
                child: Text(
                  'Esqueceu sua senha?',
                  style: TextStyle(color: Color.fromARGB(255, 2, 70, 216)),
                ),
              ),
            ),
            SizedBox(height: 50),
            SizedBox(
              width: 250, // Ajustado para ocupar toda a largura disponível
              child: ElevatedButton(
                onPressed: () {
                  // Ação do botão "Entrar"
                },
                child: Text(
                  'Entrar',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 2, 70, 216), // Cor azul
                  padding: EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Spacer(),
            RichText(
              text: TextSpan(
                text: 'Não possui uma conta? ',
                style: TextStyle(color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Registre-se',
                    style: TextStyle(color: Color.fromARGB(255, 2, 70, 216)), // Cor azul
                    recognizer: TapGestureRecognizer()..onTap = () {
                      Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Register()),
                   );
                  },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}