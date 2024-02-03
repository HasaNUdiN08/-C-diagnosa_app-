import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diagnosa_app/pages/master_aturan_gejala.dart';
import 'package:diagnosa_app/pages/master_gejala_page.dart';
import 'package:diagnosa_app/pages/master_hasil_diagnosa_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'diagnosa_detail_history.dart';

class DashboardDiagnosaPage extends StatefulWidget {
  final String penyakit;

  DashboardDiagnosaPage({required this.penyakit});
  @override
  _DashboardDiagnosaPageState createState() => _DashboardDiagnosaPageState();
}

class _DashboardDiagnosaPageState extends State<DashboardDiagnosaPage> {
  List<Map<String, dynamic>> diagnosisHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchDiagnosisHistory();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.indigo,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Dashboard Diagnosa ${widget.penyakit}'),
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMenuButton(
                    context,
                    'Daftar Gejala',
                    MasterGejalaPage(penyakit: widget.penyakit),
                    Colors.indigo,
                    Icons.list,
                  ),
                  _buildMenuButton(
                    context,
                    'Rule',
                    MasterAturanGejalaPage(penyakit: widget.penyakit),
                    Colors.teal,
                    Icons.format_list_bulleted,
                  ),
                  _buildMenuButton(
                    context,
                    'Daftar Hasil',
                    MasterHasilDiagnosaPage(penyakit: widget.penyakit),
                    Colors.deepOrange,
                    Icons.format_list_bulleted,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Riwayat Diagnosa User',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: diagnosisHistory.length,
                  itemBuilder: (context, index) {
                    var result = diagnosisHistory[index]['hasil'];
                    var date = _formatDate(diagnosisHistory[index]['tanggal_diagnosa']?.toDate()) ?? 'No Date';

                    return Dismissible(
                      key: Key(diagnosisHistory[index].toString()), // Provide a unique key
                      onDismissed: (direction) {
                        // Delete the item from the data source
                        _deleteDiagnosis(index);
                      },
                      background: Container(
                        color: Colors.red,
                        child: Icon(Icons.delete, color: Colors.white),
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.all(4),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to another page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiagnosisDetailHistoryPage(
                                diagnosisData: diagnosisHistory[index],
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 5,
                          child: ListTile(
                            title: Text(
                              '[ ${diagnosisHistory[index]['user_name']} ] -  ${date}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              result,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String label, Widget page, Color color, IconData icon) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          )
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date != null) {
      return DateFormat('d MMMM y  HH:mm').format(date);
    }
    return 'No Date';
  }

  Future<void> _fetchDiagnosisHistory() async {
    var userResponses =
    await FirebaseFirestore.instance.collection('riwayat_diagnosa')
        .where('penyakit', isEqualTo: widget.penyakit)
        .orderBy('tanggal_diagnosa', descending: true).get();
    diagnosisHistory = userResponses.docs.map((doc) => doc.data()).toList();
    setState(() {});
  }

  void _deleteDiagnosis(int index) async {
    await FirebaseFirestore.instance.collection('riwayat_diagnosa').doc(diagnosisHistory[index]['document_id']).delete();
    setState(() {
      diagnosisHistory.removeAt(index);
    });
  }
}