import 'package:flutter/material.dart';
import '../student_pages.dart';
import '../teacher_pages.dart';
import '../settings_page.dart';
import '../disciplinesPage.dart';
import '../AlunoDisciplinesPage.dart';

const String userTypeAluno = 'Aluno';
const String userTypeProfessor = 'Professor';

// Método que retorna as páginas comuns
List<Widget> _getCommonPages(String userType) {
  return [
    SettingsPage(userType: userType),
  ];
}

// Método que retorna as páginas específicas para Aluno
List<Widget> _getAlunoPages() {
  return [
    const StudentPortfolioPage(),
    AlunoDisciplinesPage(),
  ];
}

// Método que retorna as páginas específicas para Professor
List<Widget> _getProfessorPages() {
  return [
    const TeacherPortfolioPage(),
    DisciplinesPage(),
  ];
}

// Método que retorna as páginas com base no tipo de usuário
List<Widget> getPages(String userType) {
  List<Widget> pages = _getCommonPages(userType);

  if (userType == userTypeAluno) {
    pages.insertAll(0, _getAlunoPages());
  } else if (userType == userTypeProfessor) {
    pages.insertAll(0, _getProfessorPages());
  } else {
    pages = [
      const Center(child: Text('Tipo de usuário inválido')),
    ];
  }

  return pages;
}