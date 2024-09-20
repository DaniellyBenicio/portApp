import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa o Firebase Auth
import 'package:shared_preferences/shared_preferences.dart'; 
import 'RecoverPassword.dart'; 
import 'Register.dart';
import 'package:flutter/gestures.dart';

class Login extends StatefulWidget {
  final String userType;

  const Login({super.key, required this.userType});

  @override
  // ignore: library_private_types_in_public_api
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // Gerenciar o estado de carregamento
  bool _obscurePassword = true; // Gerenciar a visibilidade da senha

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Ativa o indicador de carregamento
    });

    try {
      // ignore: unused_local_variable
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Salva o tipo de usuário no SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_type', widget.userType);

      // Navega para a tela inicial após o login bem-sucedido
      if (widget.userType == 'Professor') {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/homeProfessor');
      } else if (widget.userType == 'Aluno') {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/homeAluno');
      } else {
        // ignore: avoid_print
        print('Tipo de usuário inválido: ${widget.userType}');
      }
    } on FirebaseAuthException catch (e) {
      // Mensagens específicas para diferentes erros
      String message;
      if (e.code == 'user-not-found') {
        message = 'Nenhum usuário encontrado com esse e-mail.';
      } else if (e.code == 'wrong-password') {
        message = 'Senha incorreta. Tente novamente.';
      } else if (e.code == 'invalid-email') {
        message = 'E-mail inválido.';
      } else {
        message = 'Erro ao fazer login: ${e.message}';
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      // Mensagem genérica para outros erros
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer login: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Desativa o indicador de carregamento
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context); // Ação do botão de voltar
        },
      ),
      backgroundColor: const Color.fromRGBO(18, 86, 143, 1), 
      elevation: 0,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 35), 
          const Text(
            'Entre com E-mail',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Faça login com o seu e-mail e senha para acessar sua conta.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 350, // Largura fixa dos campos
            child: _buildTextField(
              controller: _emailController,
              label: 'Email',
              isPassword: false,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 350, // Largura fixa dos campos
            child: _buildTextField(
              controller: _passwordController,
              label: 'Senha',
              isPassword: true,
              obscureText: _obscurePassword,
              onVisibilityChanged: (isVisible) {
                setState(() {
                  _obscurePassword = !isVisible;
                });
              },
              
              onSubmitted: (value) {
                _login(); // Chama a função de login ao pressionar Enter
              },
            ),
          ),
          const SizedBox(height: 8), // Ajuste o espaço entre o campo de senha e o botão de esquecer senha
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecoverPassword()),
                );
              },
              child: const Text(
                'Esqueceu sua senha?',
                style: TextStyle(color: Color.fromRGBO(18, 86, 143, 1), ),
              ),
            ),
          ),
          const SizedBox(height: 16), // Ajuste o espaço entre o botão de esquecer senha e o botão de entrar
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                  width: 350, // Largura fixa do botão
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  const Color.fromRGBO(18, 86, 143, 1), 
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Entrar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
          const SizedBox(height: 50), // Espaço antes do texto "Não possui uma conta?"
          RichText(
            text: TextSpan(
              text: 'Não possui uma conta? ',
              style: const TextStyle(color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: 'Registre-se',
                  style: const TextStyle(color: Color.fromRGBO(18, 86, 143, 1), ),
                  recognizer: TapGestureRecognizer()..onTap = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Register(userType: widget.userType),
                      ),
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

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required bool isPassword,
  bool obscureText = false,
  ValueChanged<bool>? onVisibilityChanged,
  ValueChanged<String>? onSubmitted, // Adicionando o parâmetro onSubmitted
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        obscureText: isPassword ? obscureText : false,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color.fromRGBO(18, 86, 143, 1), ),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    if (onVisibilityChanged != null) {
                      onVisibilityChanged(obscureText);
                    }
                  },
                )
              : null,
        ),
        onSubmitted: onSubmitted, // Chama o método quando Enter é pressionado
      ),
    ],
  );
}
}
