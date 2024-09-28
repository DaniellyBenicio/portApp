import 'dart:io'; // Importa para mobile
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart'; // Importa kIsWeb
import 'package:intl/intl.dart'; // Para formatação de timestamp

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _profileImageUrl;
  String? _previousImageUrl; // Armazenar URL da imagem anterior para exclusão
  File? _imageFile; // Para mobile
  Uint8List? _webImage; // Para web

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
            _nameController.text = doc['nome'];
            _emailController.text = email;
            if (doc.data().containsKey('profileImageUrl')) {
              _profileImageUrl = doc['profileImageUrl'];
              _previousImageUrl = _profileImageUrl; // Armazenar URL da imagem anterior
            } else {
              _profileImageUrl = null;
            }
          });
        } else {
          print('Documento do usuário não encontrado para o e-mail: $email');
        }
      }
    }
  }

  // Método para selecionar uma imagem (compatível com mobile e web)
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String fileName = 'profile_$timestamp.jpg';

      if (kIsWeb) {
        // Para a web: carregar a imagem como Uint8List
        final webImage = await pickedFile.readAsBytes();
        setState(() {
          _webImage = webImage;
        });
        await _uploadImageToStorage(fileName, webImage: _webImage);
      } else {
        // Para mobile: carregar a imagem como File
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        await _uploadImageToStorage(fileName, imageFile: _imageFile);
      }
    }
  }

  // Método para fazer upload da imagem para o Firebase Storage
  Future<void> _uploadImageToStorage(String fileName,
      {File? imageFile, Uint8List? webImage}) async {
    try {
      final storage = FirebaseStorage.instance;
      String timestamp = DateTime.now().toString().replaceAll('.', '_').replaceAll(' ', '_').replaceAll(':', ''); // Formatação do timestamp
      Reference ref = storage.ref().child('profile/${fileName}_$timestamp');

      UploadTask uploadTask;

      if (kIsWeb && webImage != null) {
        // Upload para web (Uint8List)
        uploadTask = ref.putData(webImage, SettableMetadata(contentType: 'image/jpeg'));
      } else if (imageFile != null) {
        // Upload para mobile (File)
        uploadTask = ref.putFile(imageFile, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        return;
      }

      // Aguarda o upload terminar e obtém a URL do download
      uploadTask.then((res) async {
        final downloadUrl = await res.ref.getDownloadURL();

        // Apagar a imagem anterior, se existir
        if (_previousImageUrl != null) {
          await _deletePreviousImage(_previousImageUrl!);
        }

        // Atualiza o Firestore com a nova URL da imagem de perfil
        setState(() {
          _profileImageUrl = downloadUrl;
          _previousImageUrl = downloadUrl; // Atualiza a URL anterior
        });

        await _updateProfile();
      }).catchError((e) {
        print('Erro ao fazer upload da imagem: $e');
      });
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
    }
  }

  // Método para apagar a imagem anterior do Storage
  Future<void> _deletePreviousImage(String imageUrl) async {
    try {
      final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();
      print('Imagem anterior deletada com sucesso.');
    } catch (e) {
      print('Erro ao deletar imagem anterior: $e');
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
            'profileImageUrl': _profileImageUrl, // Atualiza a URL da imagem
          });

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
                    : _webImage != null
                        ? MemoryImage(_webImage!) // Para web
                        : null,
                child: _profileImageUrl == null && _webImage == null
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
              readOnly: true,
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