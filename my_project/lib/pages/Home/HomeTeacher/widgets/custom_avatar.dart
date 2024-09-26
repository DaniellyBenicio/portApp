import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  final String? profileImageUrl;
  final String? teacherName;

  const CustomAvatar({Key? key, this.profileImageUrl, this.teacherName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
          ? NetworkImage(profileImageUrl!)
          : null,
      backgroundColor: profileImageUrl == null || profileImageUrl!.isEmpty
          ? const Color.fromRGBO(18, 86, 143, 1)
          : Colors.transparent,
      child: profileImageUrl == null || profileImageUrl!.isEmpty
          ? Text(
              teacherName?.substring(0, 1).toUpperCase() ?? '',
              style: const TextStyle(fontSize: 20, color: Colors.white),
            )
          : null,
    );
  }
}