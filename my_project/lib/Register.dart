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

  bool _obscurePassword = true; // Gerenciar a visibilidade da senha
  bool _obscureConfirmPassword = true; // Gerenciar a visibilidade da confirmação da senha

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
            email: _emailController.text,
            nome: _nameController.text,
            tipo: widget.userType,
            infoAdicional: widget.userType == 'Aluno'
                ? null
                : _additionalInfoController.text, // Somente para professor
          );

          // Mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cadastro realizado com sucesso!')),
          );

          Navigator.pop(context); // Navega de volta após o registro
        }
      } catch (e) {
        // Mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar: ${e.toString()}')),
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
        title: Text('Cadastro'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              controller: _nameController,
              label: 'Nome Completo',
              isPassword: false,
            ),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              isPassword: false,
            ),
            _buildTextField(
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
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Confirmar Senha',
              isPassword: true,
              obscureText: _obscureConfirmPassword,
              onVisibilityChanged: (isVisible) {
                setState(() {
                  _obscureConfirmPassword = !isVisible;
                });
              },
            ),
            if (widget.userType == 'Professor') ...[
              _buildTextField(
                controller: _additionalInfoController,
                label: 'Formação',
                isPassword: false,
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Cadastrar'),
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
