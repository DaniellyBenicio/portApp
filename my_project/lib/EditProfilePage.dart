import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _profileImageUrl; // URL da imagem do perfil

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final firestore = FirebaseFirestore.instance;
      final email = user.email;

      if (email != null) {
        final querySnapshot = await firestore
            .collection('Usuarios')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          setState(() {
            _nameController.text = doc['nome']; // Nome do usuário
            _emailController.text = email; // E-mail do usuário
            _profileImageUrl = doc['profileImageUrl']; // URL da imagem do perfil
          });
        } else {
          print('Documento do usuário não encontrado para o e-mail: $email');
        }
      }
    }
  }

  Future<void> _updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final firestore = FirebaseFirestore.instance;
      final email = user.email;

      if (email != null) {
        final querySnapshot = await firestore
            .collection('Usuarios')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final docId = querySnapshot.docs.first.id;
          await firestore.collection('Usuarios').doc(docId).update({
            'nome': _nameController.text,
            'profileImageUrl': _profileImageUrl, // Atualizar URL da imagem do perfil se necessário
          });

          // Exibir uma mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Perfil atualizado com sucesso!'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          print('Documento do usuário não encontrado para o e-mail: $email');
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Aqui você pode enviar a imagem para um armazenamento, como Firebase Storage, e obter a URL
      // Atualize a URL da imagem do perfil com a URL retornada do armazenamento
      setState(() {
        _profileImageUrl = pickedFile.path; // Atualize com o caminho da imagem local ou URL
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : null,
                child: _profileImageUrl == null
                    ? Icon(Icons.camera_alt, size: 50)
                    : null,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome Completo',
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
              readOnly: true, // Campo de e-mail apenas leitura
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
