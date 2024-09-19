import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_project/services/firestore_service.dart';

class DeleteAccountPage extends StatefulWidget {
  @override
  _DeleteAccountPageState createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _obscurePassword = true;

  String _errorMessage = '';
  String _successMessage = '';

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmação de Exclusão'),
          content: Text('Tem certeza de que deseja excluir sua conta? Esta ação é irreversível.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Excluir'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
            ),
          ],
        );
      },
    );
  }

 Future<void> _deleteAccount() async {
  final password = _passwordController.text;

  try {
    final user = _auth.currentUser;

    if (user == null) {
      setState(() {
        _errorMessage = 'Usuário não encontrado.';
      });
      return;
    }

    // Reautenticar o usuário
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);

    final email = user.email!; // Use o email para buscar o ID do documento
    print('Email do Firebase Auth: $email');

    // Utilizando FirestoreService para buscar o ID do documento
    final firestoreService = FirestoreService();
    final documentId = await firestoreService.getDocumentIdByEmail(email);

    if (documentId == null) {
      setState(() {
        _errorMessage = 'Documento do usuário não encontrado no Firestore.';
      });
      return;
    }

    print('ID do documento Firestore: $documentId');

    // Excluir o documento do Firestore
    await FirebaseFirestore.instance.collection('Usuarios').doc(documentId).delete();
    print('Documento do usuário excluído com sucesso.');

    // Excluir a conta do Firebase Auth
    await user.delete();

    setState(() {
      _successMessage = 'Conta excluída com sucesso.';
    });

    // Navegar para a página de login
    Navigator.pushReplacementNamed(context, '/login');
  } catch (e) {
    setState(() {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'wrong-password':
            _errorMessage = 'Senha incorreta.';
            break;
          case 'user-not-found':
            _errorMessage = 'Usuário não encontrado.';
            break;
          case 'requires-recent-login':
            _errorMessage = 'Reautenticação necessária. Faça login novamente.';
            break;
          default:
            _errorMessage = 'Ocorreu um erro. Tente novamente.';
        }
      } else {
        _errorMessage = 'Ocorreu um erro. Tente novamente.';
      }
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Excluir Conta'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Digite sua senha para confirmar a exclusão da conta:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Senha Atual',
                errorText: _errorMessage.isEmpty ? null : _errorMessage,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showConfirmationDialog,
              child: Text('Excluir Conta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                padding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            if (_successMessage.isNotEmpty) ...[
              SizedBox(height: 20),
              Text(
                _successMessage,
                style: TextStyle(color: Colors.green, fontSize: 16),
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
