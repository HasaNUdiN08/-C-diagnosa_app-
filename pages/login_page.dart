import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diagnosa_app/pages/home_page.dart';
import 'package:diagnosa_app/pages/register_page.dart';
import 'package:diagnosa_app/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

void _setSession(User user) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('user', jsonEncode(user.toJson()));
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final CollectionReference users = FirebaseFirestore.instance.collection('users');
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  String email = "";
  String password = "";
  bool isLoading = false;
  String errorMessage = "";

  void _onLoginWithEmailAndPassword() async {
    if (_formKey.currentState?.validate() ?? true) {
      try {
        setState(() {
          isLoading = true;
        });

        firebase_auth.UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        QuerySnapshot querySnapshot = await users.where('email', isEqualTo: userCredential.user?.email).get();
        List<QueryDocumentSnapshot> documents = querySnapshot.docs;

        if (documents.isNotEmpty) {
          final json = documents.first.data();
          _setSession(User.fromJson(json as Map<String, dynamic>));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        } else {
          setState(() {
            errorMessage = "User not found in Firestore";
          });
        }
      } catch (err) {
        setState(() {
          errorMessage = "Email atau password yang anda masukkan salah";
        });
        print("Error: $err");
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _onLoginWithGoogle() async {
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

  Future<firebase_auth.UserCredential> _signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;

      firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
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
              Colors.blue.shade400,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 80),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeInUp(duration: Duration(milliseconds: 1000),
                      child: const Text("Login", style: TextStyle(color: Colors.white, fontSize: 40))),
                  SizedBox(height: 10),
                  FadeInUp(duration: Duration(milliseconds: 1300),
                      child: const Text("Selamat Datang Kembali di Diagnosa App", style: TextStyle(color: Colors.white, fontSize: 18))),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(height: 60),
                        FadeInUp(
                          duration: Duration(milliseconds: 1400),
                          child: isLoading
                              ? const Center(
                            child: CircularProgressIndicator(),
                          )
                              : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(189, 208, 227, 1.0),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                )
                              ],
                            ),
                            child: Column(
                              children: <Widget>[
                                buildTextField("Email", (value) => email = value),
                                buildPasswordField("Password", (value) => password = value),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                        if (errorMessage.isNotEmpty)
                          isLoading
                              ? Container()
                              :Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              errorMessage,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        SizedBox(height: 40),
                        FadeInUp(
                          duration: Duration(milliseconds: 1600),
                          child: isLoading
                              ? Container()
                              : MaterialButton(
                            onPressed: _onLoginWithEmailAndPassword,
                            height: 50,
                            color: Colors.blue[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Center(
                              child: Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: FadeInUp(
                                duration: Duration(milliseconds: 1800),
                                child: isLoading
                                    ? Container()
                                    : MaterialButton(
                                  onPressed: _onLoginWithGoogle,
                                  height: 50,
                                  color: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: const Center(
                                    child: Text("Login with Google", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegisterPage()),
                            );
                          },
                          child: isLoading
                              ? Container()
                              :const Text(
                            "Belum punya akun? Register di sini",
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String hintText, Function(String) onChanged) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget buildPasswordField(String hintText, Function(String) onChanged) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
