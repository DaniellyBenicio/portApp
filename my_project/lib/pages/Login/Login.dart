import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa o Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'RecoverPassword.dart'; 
import 'Register.dart';
import 'package:flutter/gestures.dart';

//Define a classe Login que é um StatefulWidget para permitir gerenciamento de estado

class Login extends StatefulWidget {
  final String userType; // Tipo de usuário passado como parâmetro 

  const Login({super.key, required this.userType});

  @override
  // ignore: library_private_types_in_public_api
  _LoginState createState() => _LoginState(); // Cria o estado do Login
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController(); // Controla o campo de email
  final TextEditingController _passwordController = TextEditingController(); // Controla o campo de senha
  bool _isLoading = false; // Gerencia o estado de carregamento
  bool _obscurePassword = true; // Gerencia a visibilidade da senha

  // Adiciona a instância do Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Função assíncrona para fazer login
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
      _isLoading = true;
    });

    try {
      // Autentica o usuário
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Obtém os dados do usuário autenticado
      final userSnapshot = await _db.collection('Usuarios').where('email', isEqualTo: email).get();

      if (userSnapshot.docs.isNotEmpty) {
        // Obtém os dados do primeiro usuário correspondente
        final userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
        final userType = userData['tipo'];

        // Verifica se o tipo de usuário corresponde ao que foi selecionado
        if (userType != widget.userType) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tem certeza que você é ${widget.userType}? Selecione o seu tipo corretamente para realizar o login!.')),
          );
          // Aqui você pode redirecionar para a aba correspondente, se desejar
          Navigator.pop(context); // Fecha a tela de login
          return; // Sai da função
        }

        // Navega para a tela inicial com base no tipo de usuário
        if (userType == 'Professor') {
          Navigator.pushReplacementNamed(context, '/homeProfessor');
        } else if (userType == 'Aluno') {
          Navigator.pushReplacementNamed(context, '/homeAluno');
        } else {
          print('Tipo de usuário inválido: $userType');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não encontrado no banco de dados.')),
        );
      }
    } on FirebaseAuthException catch (e) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer login: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
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
          Navigator.pop(context);
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
                  MaterialPageRoute(builder: (context) => RecoverPassword()),//Navega para a tela de recuperação de senha
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

Widget _buildTextField({//Função para criar os campos de texto (e-mail e senha)
  required TextEditingController controller,
  required String label,
  required bool isPassword,
  bool obscureText = false,
  ValueChanged<bool>? onVisibilityChanged,
  ValueChanged<String>? onSubmitted, //Parâmetro para acionar o login ao pressionar Enter
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
