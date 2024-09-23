import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_project/services/firestore_service.dart';

class DeleteAccountPage extends StatefulWidget {
  @override
  _DeleteAccountPageState createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _passwordController = TextEditingController(); //Controlador para o campo de senha
  final _auth = FirebaseAuth.instance; //Instância do Firebase Auth
  bool _obscurePassword = true; //Variável para ocultar/mostrar a senha

  String _errorMessage = '';
  String _successMessage = '';

Future<void> _showConfirmationDialog() async {
    //Método para mostrar um diálogo de confirmação para exclusão da conta
    return showDialog<void>(
      context: context,
      barrierDismissible: false, //Impede que o diálogo seja fechado ao tocar fora dele
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmação de Exclusão'),
          content: const Text('Tem certeza de que deseja excluir sua conta? Esta ação é irreversível.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'), //Botão de cancelar
              onPressed: () {
                Navigator.of(context).pop(); //Fecha o diálogo
              },
            ),
            TextButton(
              child: const Text('Excluir'), //Botão para confirmar a exclusão
              onPressed: () {
                Navigator.of(context).pop(); //Fecha o diálogo
                _deleteAccount(); //Chama o método para excluir a conta
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    //Método para excluir a conta do usuário.
    final password = _passwordController.text; //Obtém a senha digitada

    try {
      final user = _auth.currentUser; //Obtém o usuário autenticado

      if (user == null) {
        setState(() {
          _errorMessage = 'Usuário não encontrado.'; //Mensagem de erro se o usuário não estiver autenticado.
        });
        return;
      }

      //Reautenticar o usuário com a senha fornecida
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential); //Reautentica o usuário

      final email = user.email!; //Obtém o email do usuário.
      print('Email do Firebase Auth: $email');

      //Utiliza FirestoreService para buscar o ID do documento associado ao usuário
      final firestoreService = FirestoreService();
      final documentId = await firestoreService.getDocumentIdByEmail(email);

      if (documentId == null) {
        setState(() {
          _errorMessage = 'Documento do usuário não encontrado no Firestore.'; //Mensagem se o documento não for encontrado
        });
        return;
      }

      print('ID do documento Firestore: $documentId');

      //Excluir o documento do Firestore
      await FirebaseFirestore.instance.collection('Usuarios').doc(documentId).delete();
      print('Documento do usuário excluído com sucesso.');

      //Excluir a conta do Firebase Auth
      await user.delete();

      setState(() {
        _successMessage = 'Conta excluída com sucesso.'; 
      });

      //Navegar para a página de login após exclusão.
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() {
        //Tratamento de erros para diferentes cenários
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'wrong-password':
              _errorMessage = 'Senha incorreta.'; //Ssenha incorreta
              break;
            case 'user-not-found':
              _errorMessage = 'Usuário não encontrado.'; //Se o usuário não for encontrado
              break;
            case 'requires-recent-login':
              _errorMessage = 'Reautenticação necessária. Faça login novamente.'; //Se reautenticação for necessária
              break;
            default:
              _errorMessage = 'Ocorreu um erro. Tente novamente.'; //Mensagem padrão de erro.
          }
        } else {
          _errorMessage = 'Ocorreu um erro. Tente novamente.'; 
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //Método que constrói a interface do usuário
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excluir Conta'), 
        centerTitle: true, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Digite sua senha para confirmar a exclusão da conta:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), 
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController, //Controlador do campo de senha
              obscureText: _obscurePassword, //Oculta a senha se necessário
              decoration: InputDecoration(
                labelText: 'Senha Atual', 
                errorText: _errorMessage.isEmpty ? null : _errorMessage, 
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility, 
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword; //Alterna a visibilidade da senha
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showConfirmationDialog, //Exibe o diálogo de confirmação
              child: const Text('Excluir Conta'), 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, 
                foregroundColor: Colors.white, 
                minimumSize: const Size(double.infinity, 50), 
                padding: const EdgeInsets.symmetric(horizontal: 16), 
              ),
            ),
            if (_successMessage.isNotEmpty) ...[ 
              const SizedBox(height: 20),
              Text(
                _successMessage,
                style: const TextStyle(color: Colors.green, fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

extension on Map<String, dynamic> {
  get id => null; 
}