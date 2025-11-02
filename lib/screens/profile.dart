import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // display static profile image
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/profile_placeholder.png'),
              ),
            ),
            // display user password
            const SizedBox(height: 10),
            Text(
              'Email: ${user?.email ?? 'No email available'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              'Account Created: ${user?.metadata.creationTime?.toLocal().toString().split(' ').first ?? 'N/A'}',
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 10),
            Text(
              'Last Sign In: ${user?.metadata.lastSignInTime?.toLocal().toString().split(' ').first ?? 'N/A'}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
