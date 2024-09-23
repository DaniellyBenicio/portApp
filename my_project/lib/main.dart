import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Seletor.dart'; 
import 'HomePage.dart';
import 'Settings_Page.dart'; 
import 'EditProfilePage.dart';
import 'ChangePasswordPage.dart';
import 'DeleteAccountPage.dart';
import 'AboutUsPage.dart'; 
import 'Login.dart';
import 'Register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializando Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Seletor(), // Home permanece como Seletor
      routes: {
        '/homeAluno': (context) => const HomePage(userType: 'Aluno'),
        '/homeProfessor': (context) => const HomePage(userType: 'Professor'),
        '/settingsAluno': (context) => const SettingsPage(userType: 'Aluno'), 
        '/settingsProfessor': (context) => const SettingsPage(userType: 'Professor'),
        '/editProfile': (context) => EditProfilePage(),
        '/changePassword': (context) => ChangePasswordPage(),
        '/deleteAccount': (context) => DeleteAccountPage(),
        '/aboutUs': (context) => const AboutUsPage(),
        '/login': (context) => const Login(userType: ''),
        '/LoginAluno': (context) => const Login(userType: 'Aluno'),
        '/LoginProfessor': (context) => const Login(userType: 'Professor'),
        '/RegisterAluno': (context) => const Register(userType: 'Aluno'),
        '/RegisterProfessor': (context) => const Register(userType: 'Professor'),
    
      },
  
    );
  }
}
