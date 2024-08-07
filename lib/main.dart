import 'package:flutter/material.dart';
import 'package:taskify_app/src/appwrite/appwrite.dart';
import 'package:taskify_app/src/myapp.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupAppwrite();
  runApp(const MyApp());
}
