import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskify_app/src/appwrite/appwrite.dart';
// import 'package:url_shortner/appWrite/app_write.dart';
import 'package:uuid/uuid.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  bool _islogin = true;

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (value) {
                  _email = value!.trim();
                },
                validator: (value) {
                  if (value!.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSaved: (value) {
                  _password = value!;
                },
                validator: (value) {
                  if (value!.trim().isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        _islogin ? _login() : _signup();
                      },
                      child: Text(_islogin ? 'Login' : 'Signup'),
                    ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        _islogin = !_islogin;
                      });
                    },
                    child: Text(!_islogin ? 'Login' : 'Signup')),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> getSessionFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_id');
  }

  Future<void> logout() async {
    try {
      final session_id = await getSessionFromSharedPreferences();
      if (session_id != null) {
        // Call deleteSession to remove the current session
        await account.deleteSession(sessionId: session_id);
        print('Session deleted successfully');
      } else {
        print('No session found');
      }
    } catch (e) {
      // Handle errors, such as network issues or unauthorized access
      print('Error deleting session: $e');
    }
  }

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      setupAppwrite();

      try {
        final result = await account.create(
          userId: const Uuid().v4(), // Generates a unique user ID
          email: _email,
          password: _password,
        );
        // Handle successful signup
        print('Signup successful: ${result.toString()}');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Signup successful'),
        ));
        await _createAndSaveSession();
        Navigator.pushNamed(context, '/home');
        // Navigate to login or another page
      } catch (e) {
        // Handle signup failure
        print('Signup failed: $e');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Signup failed: $e'),
        ));
      } finally {
        setState(() {
          _isLoading = false;
          // Navigator.push(context, MaterialPageRoute(builder: (context) => ())
        });
      }
    }
  }

  Future<void> _createAndSaveSession() async {
    try {
      // Create session
      final sessionResult = await account.createEmailPasswordSession(
        email: _email,
        password: _password,
      );

      // Save session ID to shared preferences
      _saveSession(sessionResult.$id);
    } catch (e) {
      print('Session creation failed: $e');
      rethrow; // Propagate the error to the calling method
    }
  }

  void _saveSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_id', sessionId);
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      setupAppwrite();

      try {
        final result = await account.createEmailPasswordSession(
          email: _email,
          password: _password,
        );
        // Handle successful login
        print('Login successful: ${result.toString()}');
        _saveSession(result.$id); // Save session ID
        // Navigate to another page or show success message
        // ignore: use_build_context_synchronously
        Navigator.popAndPushNamed(context, '/home');
      } catch (e) {
        // Handle login failure
        print('Login failed: $e');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login failed: $e'),
        ));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// The function `checkSession` checks if a user session exists and navigates to the home screen if it
  /// does, otherwise navigates to the login screen.
  Future<void> checkSession() async {
    try {
      final session_id = await getSessionFromSharedPreferences();
      if (session_id != null) {
        // Call deleteSession to remove the current session
        Navigator.popAndPushNamed(context, '/home');
      }
    } catch (e) {
      // Handle errors, such as network issues or unauthorized access
      print('Error deleting session: $e');
    }
  }
}
