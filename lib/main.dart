import 'package:flutter/material.dart';
import 'package:taskboard/screens/addform.dart';
import 'package:taskboard/screens/auth_gate.dart';
import 'package:taskboard/screens/home.dart';
import 'package:taskboard/screens/item.dart';
import 'package:taskboard/screens/login.dart';
import 'package:taskboard/screens/register.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Task board App",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthGate(),
      routes: {
        "/add": (_) => const AddForm(),
        "/items": (_) => const Item(),
        "/login": (_) => const LoginScreen(),
        "/register": (_) => const RegisterScreen(),
      },
    );
  }
}
