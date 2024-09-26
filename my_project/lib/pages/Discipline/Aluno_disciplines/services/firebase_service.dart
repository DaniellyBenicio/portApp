import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> matricularAluno(String disciplinaId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('Usuário não autenticado');
  }

  await FirebaseFirestore.instance.collection('Matriculas').add({
    'alunoUid': user.uid,
    'disciplinaId': disciplinaId,
  });
}

void handleError(String message, dynamic error) {
  print('$message: ${error.runtimeType}: $error');
  throw Exception('$message: ${error.toString()}');
}