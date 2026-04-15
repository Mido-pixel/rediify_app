import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // ✅ Navigate back to LoginScreen
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ Rediify logo
            Image.asset('assets/images/REdiify.png', height: 120),
            const SizedBox(height: 20),
            const Text(
              "Welcome to Rediify!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Example: navigate back to signup if needed
                Navigator.pushReplacementNamed(context, '/signup');
              },
              child: const Text("Go to Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
