
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'profile_page.dart';

User? currentUser;

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _dateOfBirthController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  String? _selectedGender;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _checkSession();
    await _fetchUserData();
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

  Future<void> _fetchUserData() async {
    try {
      final currentUserEmail = currentUser?.email;
      final CollectionReference users = _firestore.collection('users');

      if (currentUserEmail != null) {
        QuerySnapshot querySnapshot =
        await users.where('email', isEqualTo: currentUser?.email).get();
        List<QueryDocumentSnapshot> documents = querySnapshot.docs;

        if (documents.isNotEmpty) {
          final userData = documents.first.data() as Map<String, dynamic>;

          setState(() {
            _nameController.text = userData['name'] ?? '';
            _emailController.text = userData['email'] ?? '';
            _dateOfBirthController.text = userData['dateOfBirth'] ?? '';
            _addressController.text = userData['address'] ?? '';
            _selectedGender = userData['gender'] ?? null; // Set to null if data is null
          });
        }
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  Future<void> _updateProfile() async {
    try {
      final currentUserEmail = currentUser?.email;

      if (currentUserEmail != null) {
        final CollectionReference users =
        FirebaseFirestore.instance.collection('users');

        await users
            .where('email', isEqualTo: currentUserEmail)
            .get()
            .then((QuerySnapshot querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            final userDoc = querySnapshot.docs.first;
            userDoc.reference.update({
              'name': _nameController.text,
              'email': _emailController.text,
              'dateOfBirth': _dateOfBirthController.text,
              'address': _addressController.text, // Include address
              'gender': _selectedGender,
            });
          }
        });

        QuerySnapshot querySnapshot =
        await users.where('email', isEqualTo: currentUserEmail).get();
        List<QueryDocumentSnapshot> documents = querySnapshot.docs;
        if (documents.isNotEmpty) {
          final json = documents.first.data();
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'user', jsonEncode(User.fromJson(json as Map<String, dynamic>).toJson()));
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(),
          ),
        );
      }
    } catch (error) {
      print('Error updating user profile: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                enabled: false,
              ),
              // Date of Birth text field with date picker
              TextField(
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _dateOfBirthController.text =
                      selectedDate.toLocal().toString().split(' ')[0];
                    });
                  }
                },
                controller: _dateOfBirthController,
                decoration: const InputDecoration(labelText: 'Tanggal Lahir'),
              ),
              // Address text field
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              // Gender dropdown
              DropdownButtonFormField<String>(
                value: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                items: <String?>['Laki-laki', 'Perempuan']
                    .map<DropdownMenuItem<String>>((String? value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value ?? ''),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Jenis Kelamin',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
