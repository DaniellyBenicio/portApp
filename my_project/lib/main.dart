import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; //integra firebase
import 'firebase_options.dart';
import 'Seletor.dart'; 
import 'pages/Home/home_page.dart';
import 'Settings_Page.dart'; 
import 'pages/Profile/EditProfilePage.dart';
import 'pages/Profile/ChangePasswordPage.dart';
import 'pages/Profile/DeleteAccountPage.dart';
import 'pages/Profile/AboutUsPage.dart'; 
import 'pages/Login/Login.dart';
import 'pages/Login/Register.dart';

void main() async {
  // Garante a inicialização dos widgets do Flutter antes que qualquer ação seja realizada
  WidgetsFlutterBinding.ensureInitialized();

  //Inicializa o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //inicia o app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {//Método build para construção da interface do aplicativo
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Seletor(), //Define que o início será a page seletor
      routes: {
        //Define as rotas que podem ser navegadas no aplicativo
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
