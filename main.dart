import 'dart:convert';
import 'package:diagnosa_app/pages/home_page.dart';
import 'package:diagnosa_app/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'models/user.dart';

User? currentUser;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _checkSession();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

Future<void> _checkSession() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final json = prefs.getString('user');
  if (json != null) {
    currentUser = User.fromJson(jsonDecode(json));
  } else {
    currentUser = null;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diagnosa App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: currentUser == null
          ? LoginPage(
      )
          : HomePage(),
    );
  }
}
