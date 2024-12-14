import 'package:flutter/material.dart';
import 'package:ns/screens/home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordCOntroller = TextEditingController();

  final String userName = 'User';
  final String pass = 'Password';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(
              height: 80,
            ),
            Column(
              children: [
                TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'User Name',
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            TextFormField(
              controller: _passwordCOntroller,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(
              height: 60,
            ),
            ElevatedButton(
                onPressed: () {
                  if (_usernameController.text == userName &&
                      _passwordCOntroller.text == pass) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MediaCaptureApp()));
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder()
                ),
                child: const Text('Submit')),
              ],
            ),
                const SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }
}
