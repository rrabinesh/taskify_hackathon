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

Future<void> logout(context) async {
  try {
    final session_id = await getSessionFromSharedPreferences();
    if (session_id != null) {
      // Call deleteSession to remove the current session
      await account.deleteSession(sessionId: session_id);
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      print('Session deleted successfully');
    } else {
      print('No session found');
    }
  } catch (e) {
    // Handle errors, such as network issues or unauthorized access
    print('Error deleting session: $e');
  }

}
