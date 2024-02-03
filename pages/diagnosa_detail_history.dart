
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DiagnosisDetailHistoryPage extends StatelessWidget {
  final Map<String, dynamic> diagnosisData;

  DiagnosisDetailHistoryPage({required this.diagnosisData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diagnosis Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSection('Penyakit', diagnosisData['penyakit'] ?? 'No Result', Icons.local_hospital, Colors.blueGrey),
            _buildSection('User', diagnosisData['user_name'] ?? 'No Result', Icons.person, Colors.blueGrey),
            _buildSection('Hasil Diagnosa', '${diagnosisData['hasil']} ', Icons.assignment, Colors.blueGrey),
            _buildSection('Saran', '${diagnosisData['saran']} ', Icons.assignment, Colors.blueGrey),
            _buildSection('Persentase', '${diagnosisData['bobot']} ', Icons.assignment, Colors.blueGrey),
            _buildSection(
              'Tanggal Diagnosa',
              _formatDate(diagnosisData['tanggal_diagnosa']?.toDate()) ?? 'No Date',
              Icons.calendar_today,
              Colors.blueGrey,
            ),
            SizedBox(height: 20),
            _buildQuestionAnswers(diagnosisData['answer_list']),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 30),
                SizedBox(width: 10), // Add some spacing between icon and title
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }


  String _formatDate(DateTime? date) {
    if (date != null) {
      return DateFormat.yMMMMd().format(date);
    }
    return 'No Date';
  }

  Widget _buildQuestionAnswers(List<dynamic>? questions) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'History Pertanyaan dan Jawaban',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            if (questions != null && questions.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: questions.map<Widget>((question) => _buildQuestionAnswer(question)).toList(),
              )
            else
              Text(
                'No Questions and Answers',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionAnswer(Map<String, dynamic> question) {
    return Container(
      width: double.infinity, // Set the width to fill the screen
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pertanyaan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                question['pertanyaan'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 10),
              const Text(
                'Jawaban',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                question['jawaban'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
