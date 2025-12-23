import 'package:flutter/material.dart';
import 'package:taskboard/screens/addform.dart';
import 'package:taskboard/screens/auth_gate.dart';
import 'package:taskboard/screens/item.dart';
import 'package:taskboard/services/auth_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _refreshToken = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await AuthStorage.clear();
              if (!mounted) {
                return;
              }
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthGate()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu),
        ),
        title: const Text("Task board App"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Item(key: ValueKey(_refreshToken)),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddForm()));
          if (created == true) {
            setState(() => _refreshToken++);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
