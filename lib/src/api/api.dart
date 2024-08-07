import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskify_app/src/appwrite/appwrite.dart';

Future<String?> getSessionFromSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('session_id');
}

Future getCurrentUser() async {
  return await account.get();
}

Future<void> _removeSession() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(
      'session_id'); // This will remove the session_id from SharedPreferences
}

Future<void> logout(BuildContext context) async {
  try {
    final session_id = await getSessionFromSharedPreferences();
    if (session_id != null) {
      await _removeSession();
      await account.deleteSession(sessionId: session_id);
      Navigator.popAndPushNamed(context, '/'); // Navigate to the login screen
      print('Session deleted and removed from SharedPreferences successfully');
    } else {
      print('No session found');
    }
  } catch (e) {
    print('Error deleting session: $e');
    // Optionally show a message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error deleting session: $e')),
    );
  }
}
