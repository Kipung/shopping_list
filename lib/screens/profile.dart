import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            CircleAvatar(radius: 36, child: Icon(Icons.person, size: 36)),
            SizedBox(height: 12),
            Text('User Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('email@example.com', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 20),
            Text('TODO: Add profile details and settings here.'),
          ],
        ),
      ),
    );
  }
}
