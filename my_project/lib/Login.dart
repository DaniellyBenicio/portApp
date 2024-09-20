import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa o Firebase Auth
import 'package:shared_preferences/shared_preferences.dart'; 
import 'RecoverPassword.dart'; 
import 'Register.dart';
import 'package:flutter/gestures.dart';

class Login extends StatefulWidget {
  final String userType;

  const Login({Key? key, required this.userType}) : super(key: key);

  @override
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
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Salva o tipo de usuário no SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_type', widget.userType);

      // Navega para a tela inicial após o login bem-sucedido
      if (widget.userType == 'Professor') {
        Navigator.pushReplacementNamed(context, '/homeProfessor');
      } else if (widget.userType == 'Aluno') {
        Navigator.pushReplacementNamed(context, '/homeAluno');
      } else {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      // Mensagem genérica para outros erros
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
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Ação do botão de voltar
          },
        ),
        backgroundColor: Colors.blue,
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
                fontSize: 24,
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
            SizedBox(height: 32),
            Container(
              width: 350, // Largura fixa dos campos
              child: _buildTextField(
                controller: _emailController,
                label: 'Email',
                isPassword: false,
              ),
            ),
            SizedBox(height: 16),
            Container(
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
              ),
            ),
            SizedBox(height: 8), // Ajuste o espaço entre o campo de senha e o botão de esquecer senha
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RecoverPassword()),
                  );
                },
                child: Text(
                  'Esqueceu sua senha?',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 16), // Ajuste o espaço entre o botão de esquecer senha e o botão de entrar
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: 350, // Largura fixa do botão
                    child: ElevatedButton(
                      onPressed: _login,
                      child: Text(
                        'Entrar',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
            SizedBox(height: 20), // Espaço antes do texto "Não possui uma conta?"
            RichText(
              text: TextSpan(
                text: 'Não possui uma conta? ',
                style: TextStyle(color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Registre-se',
                    style: TextStyle(color: Colors.blue),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? obscureText : false,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue),
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
        ),
      ],
    );
  }
}
