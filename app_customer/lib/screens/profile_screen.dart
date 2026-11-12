import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = AuthService().getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Profil gagal dimuat: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('Data profil tidak ditemukan.'));
          }

          final name = user['name']?.toString() ?? '';
          final email = user['email']?.toString() ?? '';
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 48,
                backgroundColor: const Color(0xFFE8EAF6),
                child: Text(
                  name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name.isEmpty ? 'Nama belum tersedia' : name,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Nama'),
                      subtitle: Text(name.isEmpty ? '-' : name),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email'),
                      subtitle: Text(email.isEmpty ? '-' : email),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
