import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_locator/services/login_service.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  LoginService loginService = LoginService();
  @override
  void dispose() {
    // TODO: implement dispose
    _formKey.currentState!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _formKey,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Hospital Locator'),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasData) {
            User? user = snapshot.data;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome, ${user?.displayName}!'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/map');
                    },
                    child: const Text('Go To Hospital Locator'),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: SizedBox(
                height: 50,
                child: SignInButton(
                  Buttons.google,
                  onPressed: () async {
                    UserCredential? user =
                        await loginService.signInWithGoogle();

                    if (user != null) {
                      Navigator.pushReplacementNamed(context, '/map');
                    }
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
