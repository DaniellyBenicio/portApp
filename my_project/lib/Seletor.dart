import 'package:flutter/material.dart';
import 'Login.dart';
import 'Register.dart'; // Importa a tela de registro

class Seletor extends StatelessWidget {
  const Seletor({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: UserSelectionBody(),
    );
  }
}

class UserSelectionBody extends StatelessWidget {
  const UserSelectionBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600, 
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Quem é você?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecione o tipo de usuário para continuar',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UserTypeCard(
                    icon: Icons.school,
                    label: 'Aluno',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Login(userType: 'Aluno'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 50),
                  UserTypeCard(
                    icon: Icons.person,
                    label: 'Professor',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Login(userType: 'Professor'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const UserTypeCard({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color.fromRGBO(18, 86, 143, 1), 
                child: Icon(
                  icon,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
