import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nextbus/Providers/authentication.dart';
import 'package:nextbus/Pages/home_page.dart';
import 'package:nextbus/app_layout.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: const Text("Next Bus Login"), automaticallyImplyLeading: false,),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.account_circle),
              label: const Text("Sign in with Google"),
              onPressed: () async {
                User? user = await authService.signInWithGoogle(context);
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AppLayout()),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_outline),
              label: const Text("Continue as Guest"),
              onPressed: () async {
                User? user = await authService.signInAsGuest(context);
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AppLayout()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
