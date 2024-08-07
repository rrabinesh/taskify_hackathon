import 'package:flutter/material.dart';
import 'package:taskify_app/src/api/api.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
          onPressed: () {
            logout(context);
          },
          child: const Text("logout")),
    );
  }
}
