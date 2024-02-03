import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class DiagnosaHistoryPage extends StatefulWidget {
  @override
  _DiagnosaHistoryPageState createState() => _DiagnosaHistoryPageState();
}

class _DiagnosaHistoryPageState extends State<DiagnosaHistoryPage> {
  FirestoreService firestoreService = FirestoreService(); // Initialize your service
  List<Map<String, dynamic>> _diagnosaHistory = [];

  @override
  void initState() {
    _loadHistoryData();
    super.initState();
  }

  Future<void> _loadHistoryData() async {
    _diagnosaHistory = await firestoreService.getDiagnosaHistoryByPenyakit('Covid');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnosa History'),
      ),
      body: _diagnosaHistory.isEmpty
          ? const Center(
        child: Text('No Diagnosa History'),
      )
          : ListView.builder(
        itemCount: _diagnosaHistory.length,
        itemBuilder: (context, index) {
          return _buildDiagnosaCard(_diagnosaHistory[index]);
        },
      ),
    );
  }

  Widget _buildDiagnosaCard(Map<String, dynamic> diagnosaData) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tanggal Diagnosa: ${diagnosaData['tanggal_diagnosa']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Penyakit: ${diagnosaData['penyakit']}',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hasil: ${diagnosaData['hasil']}',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Persentase: ${diagnosaData['persentase']}%',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Jawaban:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            // Assuming 'answerList' is a list of maps in your Firestore data structure
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (diagnosaData['answerList'] as List<dynamic>)
                  .map<Widget>((answer) {
                return Text(
                  '- ${answer['pertanyaan']}: ${answer['jawaban']}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
