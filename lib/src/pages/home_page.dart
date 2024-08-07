import 'package:flutter/material.dart';
import 'package:taskify_app/src/api/api.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Home")),
        body: Text('HOME'),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/taskCreate');
            },
            child: const Icon(Icons.add)));
  }
}
