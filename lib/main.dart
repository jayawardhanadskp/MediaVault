import 'package:flutter/material.dart';
import 'package:ns/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ns/screens/home_page.dart';
import 'package:ns/screens/login_screen.dart';

// Initialize Firebase
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MediaCaptureApp(),
    );
  }
}