import "package:flutter/material.dart";
import "package:taskboard/screens/home.dart";
import "package:taskboard/screens/login.dart";
import "package:taskboard/services/auth_storage.dart";

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthStorage.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == true) {
          return const HomePage();
        }
        return const LoginScreen();
      },
    );
  }
}
