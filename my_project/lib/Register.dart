import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_project/services/firestore_service.dart';

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

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  Future<void> _register() async {
    if (_passwordController.text == _confirmPasswordController.text) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        final uid = userCredential.user?.uid;

        if (uid != null) {
          await FirestoreService().addUser(
            email: _emailController.text,
            nome: _nameController.text,
            tipo: widget.userType,
            infoAdicional: widget.userType == 'Aluno' ? null : _additionalInfoController.text,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cadastro realizado com sucesso!')),
          );

          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Diminui o padding
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Registre-se com e-mail',
                  style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10), // Menos espaço
                const Text(
                  'Crie a sua conta para começar a usar o PortApp.',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8), // Menos espaço
                _buildTextField(
                  controller: _nameController,
                  label: 'Nome Completo',
                  isPassword: false,
                ),
                const SizedBox(height: 8), // Menos espaço
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  isPassword: false,
                ),
                const SizedBox(height: 8), // Menos espaço
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
                  onSubmitted: (value) {
                    FocusScope.of(context).nextFocus();
                  },
                ),
                const SizedBox(height: 8), // Menos espaço
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
                  onSubmitted: (value) {
                    _register();
                  },
                ),
                if (widget.userType == 'Professor') ...[
                  const SizedBox(height: 8), // Menos espaço
                  _buildTextField(
                    controller: _additionalInfoController,
                    label: 'Formação',
                    isPassword: false,
                    onSubmitted: (value) {
                      _register();
                    },
                  ),
                ],
                const SizedBox(height: 12), // Menos espaço
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16), // Diminui o padding vertical
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading 
                      ? CircularProgressIndicator(color: Colors.white) 
                      : const Text(
                          'Cadastrar',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
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
    ValueChanged<String>? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 4), // Menos espaço
        TextField(
          controller: controller,
          obscureText: isPassword ? obscureText : false,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      if (onVisibilityChanged != null) {
                        onVisibilityChanged(obscureText);
                      }
                    },
                  )
                : null,
          ),
          onSubmitted: onSubmitted,
        ),
      ],
    );
  }
}
