
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diagnosa_app/models/user.dart';
import 'package:diagnosa_app/pages/diagnosa_detail_history.dart';
import 'package:diagnosa_app/pages/login_page.dart';
import 'package:diagnosa_app/pages/edit_profile_page.dart'; // Import halaman Edit Profile
import 'package:diagnosa_app/widget/bottom_menu.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

User? currentUser;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  // Diagnosis history data
  List<Map<String, dynamic>> diagnosisHistory = [];

  @override
  void initState() {
    _initializeData();
    super.initState();

  }

  Future<void> _initializeData() async {
    await _checkSession();
    await _fetchDiagnosisHistory();
    setState(() {
      _isLoading = false;
    });
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

  Future<void> _firebaseSignOut() async {
    try {
      await firebase.FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (error) {
      print("Error signing out from Firebase: $error");
    }
  }

  Future<void> _fetchDiagnosisHistory() async {
    var userResponses = await FirebaseFirestore.instance
        .collection('riwayat_diagnosa')
        .where('email', isEqualTo: currentUser?.email)
        .orderBy('tanggal_diagnosa', descending: true)
        .get();
    diagnosisHistory = userResponses.docs
        .map((doc) => doc.data()..['document_id'] = doc.id)
        .toList();
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: Text(
                      currentUser!.name.substring(0, 1),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${currentUser?.name}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20), // Jarak antara informasi profil dan tombol "Edit Profile"
          const Text(
            ' Riwayat Diagnosa :',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView.builder(
                  itemCount: diagnosisHistory.length,
                  itemBuilder: (context, index) {
                    var result = diagnosisHistory[index]['hasil'];
                    var date = _formatDate(diagnosisHistory[index]['tanggal_diagnosa']?.toDate()) ?? 'No Date';
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiagnosisDetailHistoryPage(
                              diagnosisData: diagnosisHistory[index],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '[ ${diagnosisHistory[index]['penyakit']} ] - $date',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    result ?? 'No Result',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _showDeleteConfirmationDialog(diagnosisHistory[index]);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 2 - 30,
                margin: EdgeInsets.only(left: 20),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfilePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 2 - 30, // Lebar maksimum untuk tombol "Logout"
                margin: EdgeInsets.only(right: 20), // Margin kanan untuk tombol "Logout"
                child: ElevatedButton(
                  onPressed: () async {
                    await _firebaseSignOut();
                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.remove('user');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      'Logout',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
      bottomNavigationBar: BottomMenuBar(
        currentIndex: 1,
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date != null) {
      return DateFormat('d MMMM y  HH:mm').format(date);
    }
    return 'No Date';
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> diagnosisData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Confirmation"),
          content: const Text("Are you sure you want to delete this diagnosis?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteDiagnosis(diagnosisData);
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _deleteDiagnosis(Map<String, dynamic> diagnosisData) async {
    await FirebaseFirestore.instance.collection('riwayat_diagnosa').doc(diagnosisData['document_id']).delete();
    await _fetchDiagnosisHistory();
    setState(() {});
  }
}
