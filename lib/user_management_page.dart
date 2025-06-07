import 'package:flutter/material.dart';

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> users = [
      {"name": "İlqar Əliyev", "email": "ilqar@example.com", "role": "Admin"},
      {"name": "Zaur Məmmədov", "email": "zaur@example.com", "role": "İstifadəçi"},
      {"name": "Sevinc Quliyeva", "email": "sevinc@example.com", "role": "Moderator"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("İstifadəçilərə nəzarət"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: Colors.white,
            leading: const CircleAvatar(
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(user["name"]!),
            subtitle: Text(user["email"]!),
            trailing: Text(user["role"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${user["name"]} seçildi")),
              );
            },
          );
        },
      ),
    );
  }
}
