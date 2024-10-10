import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Definindo constantes para estilos de texto
const TextStyle headerTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Color.fromRGBO(18, 86, 143, 1),
);

const TextStyle subHeaderTextStyle = TextStyle(
  fontSize: 16,
  color: Colors.black,
);

const TextStyle labelTextStyle = TextStyle(
  fontSize: 16,
  color: Colors.black,
);

const TextStyle buttonTextStyle = TextStyle(
  color: Colors.white,
);

// Definindo constantes para cores
const Color primaryColor = Color.fromRGBO(18, 86, 143, 1);
const Color fillColor = Color(0xFFE0E0E0); // Cor de preenchimento para o TextFormField

class RecoverPassword extends StatefulWidget {
  @override
  _RecoverPasswordState createState() => _RecoverPasswordState();
}

class _RecoverPasswordState extends State<RecoverPassword> {
  final _emailController = TextEditingController(); // Controlador para o campo de e-mail
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário
  bool _loading = false; // Indicador de carregamento

  // Método para enviar o e-mail de recuperação de senha
  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) { // Valida o formulário
      setState(() {
        _loading = true; // Ativa o indicador de carregamento
      });

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim(), // Envia o e-mail para recuperação
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link de recuperação de senha enviado!'),
            backgroundColor: Colors.green,
          ),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Ocorreu um erro';
        if (e.code == 'user-not-found') {
          errorMessage = 'Usuário não encontrado';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navega de volta
          },
        ),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Recuperação de Senha',
                  style: headerTextStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Digite seu endereço de e-mail para receber um link para redefinir sua senha.',
                  style: subHeaderTextStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Email',
                        style: labelTextStyle,
                      ),
                      const SizedBox(height: 8),
                      // Ajuste o width do TextFormField
                      SizedBox(
                        width: double.infinity, // Ocupa toda a largura disponível
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: fillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: primaryColor),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira o seu e-mail'; // Validação para campo vazio
                            } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Por favor, insira um e-mail válido'; // Validação de formato
                            }
                            return null; // Se válido
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      _loading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _resetPassword, // Chama o método de reset
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Enviar link de recuperação',
                                style: buttonTextStyle,
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white, // Fundo branco
    );
  }
}