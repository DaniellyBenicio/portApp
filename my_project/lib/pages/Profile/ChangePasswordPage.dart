import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  String _errorMessage = '';
  bool _obscureCurrentPassword = true; //Controle de visibilidade da senha atual
  bool _obscureNewPassword = true; //Controle de visibilidade da nova senha
  bool _obscureConfirmPassword = true; //Controle de visibilidade da confirmação da nova senha

  //Função para alterar a senha
  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    //Verifica se as senhas novas são iguais
    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'A nova senha e a confirmação não coincidem.';
      });
      return;
    }

    try {
      final user = _auth.currentUser;

      if (user == null) {
        setState(() {
          _errorMessage = 'Usuário não encontrado.';
        });
        return;
      }

      //Cria credenciais de reautenticação
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      //Reautentica o usuário
      await user.reauthenticateWithCredential(credential);

      //Atualiza a senha no Firebase Auth
      await user.updatePassword(newPassword);

      //Após atualizar a senha, navega para a página de login
      await _navigateToLogin();
    } catch (e) {
      setState(() {
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'wrong-password':
              _errorMessage = 'Senha atual incorreta.';
              break;
            case 'weak-password':
              _errorMessage = 'A nova senha é muito fraca.';
              break;
            case 'requires-recent-login':
              _errorMessage = 'Reautenticação necessária. Faça login novamente.';
              break;
            default:
              _errorMessage = 'Ocorreu um erro. Tente novamente. Erro: ${e.message}';
          }
        } else {
          _errorMessage = 'Ocorreu um erro. Tente novamente. Erro: ${e.toString()}';
        }
      });
    }
  }

  Future<void> _navigateToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('user_type') ?? 'Aluno';

    print('Tipo de usuário armazenado: $userType'); //Testando se deu certo

    if (userType == 'Professor') {
      Navigator.pushReplacementNamed(context, '/homeProfessor'); //Rota se professor
    } else if (userType == 'Aluno') {
      Navigator.pushReplacementNamed(context, '/homeAluno'); //Rota se aluno
    } else {
      print('Tipo de usuário inválido: $userType');
      // Opcional: Navegue para uma página de erro ou mostre um alerta
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trocar Senha'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildPasswordField(
              controller: _currentPasswordController,
              labelText: 'Senha Atual',
              obscureText: _obscureCurrentPassword,
              onVisibilityChanged: (isVisible) {
                setState(() {
                  _obscureCurrentPassword = !isVisible;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              controller: _newPasswordController,
              labelText: 'Nova Senha',
              obscureText: _obscureNewPassword,
              onVisibilityChanged: (isVisible) {
                setState(() {
                  _obscureNewPassword = !isVisible;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              controller: _confirmPasswordController,
              labelText: 'Confirmar Nova Senha',
              obscureText: _obscureConfirmPassword,
              onVisibilityChanged: (isVisible) {
                setState(() {
                  _obscureConfirmPassword = !isVisible;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text('Salvar'),
              style: ElevatedButton.styleFrom(

                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 5,
                shadowColor: Colors.black.withOpacity(0.5), // Cor da sombra
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    required ValueChanged<bool> onVisibilityChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        errorText: _errorMessage.isEmpty ? null : _errorMessage,
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            onVisibilityChanged(obscureText);
          },
        ),
      ),
    );
  }
}