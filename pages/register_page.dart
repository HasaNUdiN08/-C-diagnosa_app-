import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diagnosa_app/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

void _setSession(User user) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('user', jsonEncode(user.toJson()));
}

class _RegisterPageState extends State<RegisterPage> {
  final CollectionReference users = FirebaseFirestore.instance.collection('users');
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  String name = "";
  String email = "";
  String password = "";
  bool isLoading = false;

  void _onRegisterWithGoogle() async {
    try {
      setState(() {
        isLoading = true;
      });
      firebase_auth.UserCredential userCredential = await _signInWithGoogle();
      QuerySnapshot querySnapshot = await users.where('email', isEqualTo: userCredential.user?.email).get();
      List<QueryDocumentSnapshot> documents = querySnapshot.docs;

      if (documents.isNotEmpty) {
        final json = documents.first.data();
        if (mounted) {
          _setSession(User.fromJson(json as Map<String, dynamic>));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        }
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Store user information in Firestore
      if (userCredential.user != null) {
        await users.add({
          "name": userCredential.user?.displayName,
          "email": userCredential.user?.email,
          "is_admin": false,
        });
      }
      if (mounted) {
        _setSession(User.fromJson(json as Map<String, dynamic>));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Terjadi Kesalahan, Silakan Coba Lagi'),
        ));
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onRegisterWithEmailAndPassword() async {
    try {
      setState(() {
        isLoading = true;
      });
      // Register with Email and Password
      firebase_auth.UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Store user information in Firestore
      await users.add({
        "name": name,
        "email": userCredential.user?.email,
        "is_admin": false,
      });
      // Fetch user data from Firestore
      QuerySnapshot querySnapshot =
      await users.where('email', isEqualTo: userCredential.user?.email).get();
      List<QueryDocumentSnapshot> documents = querySnapshot.docs;

      if (documents.isNotEmpty) {
        final userData = documents.first.data();
        _setSession(User.fromJson(userData as Map<String, dynamic>));
        if (mounted) {
          print("berhasil");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        }
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.message}'),
        ));
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<firebase_auth.UserCredential> _signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;

      firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      // Authenticate with Firebase using Google credentials
      return await _auth.signInWithCredential(credential);
    } catch (e) {

      throw Exception('Google Sign-In Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                colors: [
                  Colors.blue.shade900,
                  Colors.blue.shade800,
                  Colors.blue.shade400
                ]
            )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 80,),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeInUp(duration: Duration(milliseconds: 1000), child: Text("Registrasi", style: TextStyle(color: Colors.white, fontSize: 40),)),
                  SizedBox(height: 10,),
                  FadeInUp(duration: Duration(milliseconds: 1300), child: Text("Silahkan daftarkan akun anda", style: TextStyle(color: Colors.white, fontSize: 18),)),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))
                ),
                child : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,  // Add this line
                      children: <Widget>[
                        SizedBox(height: 60,),
                        FadeInUp(duration: Duration(milliseconds: 1400), child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [BoxShadow(
                                  color: Color.fromRGBO(189, 208, 227, 1.0),
                                  blurRadius: 20,
                                  offset: Offset(0, 10)
                              )]
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                                ),
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                      hintText: "Nama",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none

                                  ),
                                  onChanged: (value) {
                                    name = value;
                                  },
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                                ),
                                child: TextField(
                                  decoration: const InputDecoration(
                                      hintText: "Email",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none
                                  ),
                                  onChanged: (value) {
                                    email = value;
                                  },
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                                ),
                                child: TextField(
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      hintText: "Password",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none
                                  ),
                                  onChanged: (value) {
                                    password = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                        )),

                        SizedBox(height: 40,),
                        FadeInUp(
                          duration: Duration(milliseconds: 1800),
                          child: MaterialButton(
                            onPressed: isLoading ? null : _onRegisterWithEmailAndPassword,
                            height: 50,
                            color: Colors.blue[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: isLoading
                                  ? CircularProgressIndicator(
                                color: Colors.white,
                              )
                                  : const Text(
                                "Register",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30,),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: FadeInUp(duration: Duration(milliseconds: 1800), child: MaterialButton(
                                onPressed: _onRegisterWithGoogle,
                                height: 50,
                                color: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Center(
                                  child: Text("Daftar dengan Google", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                ),
                              )),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                          },
                          child: const Text(
                            "Sudah punya akun? Login di sini",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}