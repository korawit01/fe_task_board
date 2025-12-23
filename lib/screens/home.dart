import 'package:flutter/material.dart';
import 'package:taskboard/screens/addform.dart';
import 'package:taskboard/screens/item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
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
      body: const Item(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddForm()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
