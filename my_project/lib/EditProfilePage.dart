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
  final _nameController = TextEditingController(); //Controlador para o campo de nome
  final _emailController = TextEditingController(); //Controlador para o campo de e-mail
  final ImagePicker _picker = ImagePicker(); //Instância do ImagePicker para escolher imagens
  String? _profileImageUrl; //URL da imagem do perfil

  @override
  void initState() {
    super.initState();
    _loadUserData(); //Carrega os dados do usuário ao iniciar a página
  }

  //Método para carregar os dados do usuário do Firestore
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;//Obtém o usuário atual
    if (user != null) {
      final firestore = FirebaseFirestore.instance;
      final email = user.email;

      if (email != null) {
      //Busca o documento do usuário com base no e-mail
        final querySnapshot = await firestore
            .collection('Usuarios')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          //Atualiza os controladores com os dados do usuário
          setState(() {
            _nameController.text = doc['nome']; //Nome do usuário
            _emailController.text = email; //E-mail do usuário
            _profileImageUrl = doc['profileImageUrl']; //URL da imagem do perfil
          });
        } else {
          print('Documento do usuário não encontrado para o e-mail: $email');
        }
      }
    }
  }

  //Método para atualizar o perfil do usuário
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
            'profileImageUrl': _profileImageUrl, //Atualiza URL da imagem do perfil se necessário
          });

          //Exibe uma mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
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

  //Método para selecionar uma imagem da galeria
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      //Aqui pode enviar a imagem para um armazenamento, como Firebase Storage, e obter a URL
      //Atualiza a URL da imagem do perfil com a URL retornada do armazenamento
      setState(() {
        _profileImageUrl = pickedFile.path; //Atualiza com o caminho da imagem local ou URL
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
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
                    ? const Icon(Icons.camera_alt, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome Completo',
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
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
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
              ),
              readOnly: true, //Campo de e-mail apenas leitura
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text('Salvar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}