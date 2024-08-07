import 'package:flutter/material.dart';
import 'package:taskify_app/src/pages/home_page.dart';
import 'package:taskify_app/src/pages/login_page.dart';
import 'package:taskify_app/src/pages/task_create.dart';
// import 'package:url_shortner/pages/home.dart';
// import 'package:url_shortner/pages/listPage.dart';
// import 'package:url_shortner/pages/login_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/taskCreate':(context) => CreateTaskScreen(),
      },
    );
  }
}
