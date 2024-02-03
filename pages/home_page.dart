import 'dart:convert';
import 'package:diagnosa_app/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:diagnosa_app/widget/bottom_menu.dart';
import 'package:diagnosa_app/widget/news_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'diagnosa_page.dart';

User? currentUser;

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
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

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isLoading = true;
  @override
  void initState() {
    _initializeData();
    super.initState();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 17) {
      return 'Selamat Siang';
    } else {
      return 'Selamat Malam';
    }
  }

  Future<void> _initializeData() async {
    await _checkSession();
    setState(() {
      _isLoading = false;
    });
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
    print(currentUser?.isAdmin);
    List<DiagnosisMenu> diagnosisMenus = [
      DiagnosisMenu(
        icon: Icons.healing,
        color: Colors.blue.shade900,
        title: 'TBC',
        subtitle: 'Lakukan diagnosa untuk Tuberculosis (TBC)',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DiagnosaPage(email : currentUser?.email ?? "",name: currentUser?.name ??"",penyakit:"TBC")),
          );
        },
      ),
      DiagnosisMenu(
        icon: Icons.masks,
        color: Colors.blue.shade900,
        title: 'COVID-19',
        subtitle: 'Lakukan diagnosa untuk COVID-19',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DiagnosaPage(email : currentUser?.email ?? "",name: currentUser?.name ??"",penyakit:"Covid")),
          );
        },
      ),
      DiagnosisMenu(
        icon: Icons.health_and_safety_outlined,
        color: Colors.blue.shade900,
        title: 'Asma',
        subtitle: 'Lakukan diagnosa untuk Asma',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DiagnosaPage(email : currentUser?.email ?? "",name: currentUser?.name ??"",penyakit:"Asma")),
          );
        },
      ),
      if (currentUser?.isAdmin == true) // Tambahkan menu ini hanya jika currentUser.isAdmin == true
        ...[
          DiagnosisMenu(
            icon: Icons.dashboard,
            color: Colors.blueAccent,
            title: 'Dashboard TBC',
            subtitle: 'Kelola data TBC',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardDiagnosaPage(penyakit:'TBC')),
              );
            },
          ),
          DiagnosisMenu(
            icon: Icons.dashboard,
            color: Colors.blueAccent,
            title: 'Dashboard Covid-19',
            subtitle: 'Kelola data Covid-19',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardDiagnosaPage(penyakit:'Covid')),
              );
            },
          ),
          DiagnosisMenu(
            icon: Icons.dashboard,
            color: Colors.blueAccent,
            title: 'Dashboard Asma',
            subtitle: 'Kelola data Asma',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardDiagnosaPage(penyakit:'Asma')),
              );
            },
          ),
        ],
    ];
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Diagnosa App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${_getGreeting()} , ${currentUser!.isAdmin ? 'Admin' :''} ${currentUser?.name ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Menu Diagnosa Kesehatan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: diagnosisMenus
                .map((menu) => _buildDiagnosaMenu(
              icon: menu.icon,
              color: menu.color,
              title: menu.title,
              subtitle: menu.subtitle,
              onTap: menu.onTap,
            ))
                .toList(),
          ),
          SizedBox(height: 20),
          NewsWidget(),
          SizedBox(height: 10),
        ],
      ),
      bottomNavigationBar: BottomMenuBar(
        currentIndex: _currentIndex,
      ),
    );
  }

  Widget _buildDiagnosaMenu({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 35, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}

class DiagnosisMenu {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  DiagnosisMenu({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
