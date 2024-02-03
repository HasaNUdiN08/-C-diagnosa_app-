
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diagnosa_data.dart';

class DiagnosaPage extends StatefulWidget {
  final String email;
  final String name;
  final String penyakit;

  DiagnosaPage({required this.email, required this.name, required this.penyakit});

  @override
  _DiagnosaPageState createState() => _DiagnosaPageState();
}

class _DiagnosaPageState extends State<DiagnosaPage> {
  List<Map<String, dynamic>> _gejalaList = [];
  List<Map<String, dynamic>> _aturanList = [];
  List<bool?> _answers = [];
  int _currentQuestionIndex = 0;
  String _hasilDiagnosa = '';
  String _saranDiagnosa = '';
  String _bobotDiagnosa = '';
  bool _showLabel = true;
  Color _kodeWarna = Colors.green;

  @override
  void initState() {
    super.initState();
    _loadDataFromFirestore();
    _initializeAnswers();
  }

  void _loadDataFromFirestore() async {
    QuerySnapshot gejalaSnapshot = await FirebaseFirestore.instance.collection('master_gejala').where('penyakit', isEqualTo: widget.penyakit).get();
    QuerySnapshot aturanSnapshot = await FirebaseFirestore.instance
        .collection('master_aturan_gejala')
        .where('penyakit', isEqualTo: widget.penyakit)
        .orderBy('no', descending: false)
        .get();

    List<Map<String, dynamic>> gejalaList = [];
    List<Map<String, dynamic>> aturanList = [];

    gejalaSnapshot.docs.forEach((gejalaDoc) {
      gejalaList.add(gejalaDoc.data() as Map<String, dynamic>);
    });

    aturanSnapshot.docs.forEach((aturanDoc) {
      aturanList.add(aturanDoc.data() as Map<String, dynamic>);
    });

    setState(() {
      _gejalaList = gejalaList;
      _aturanList = aturanList;
      _answers = List<bool?>.filled(_gejalaList.length, null);
    });
  }

  void _initializeAnswers() {
    _answers = List<bool?>.filled(_gejalaList.length, null);
  }

  Widget _buildQuestionCard(Map<String, dynamic> gejala) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pertanyaan:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              gejala['pertanyaan'],
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _answerQuestion(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Ya',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _answerQuestion(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Tidak',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _answerQuestion(bool isYes) {
    setState(() {
      if (_currentQuestionIndex < _gejalaList.length) {
        _answers[_currentQuestionIndex] = isYes;
        _currentQuestionIndex++;
        if (_currentQuestionIndex < _gejalaList.length) {
          // Pindah ke pertanyaan berikutnya
        } else {
          _performDiagnosa();
        }
      }
    });
  }

  void _performDiagnosa() async {
    String hasilDiagnosa = 'Tidak ada hasil diagnosa yang ditemukan';
    String saranDiagnosa = 'Jaga Kesehatan Selalu';
    String bobotDiagnosa = '0 %';
    Color kodeWarna = Colors.green;

    if (_answers.every((answer) => answer != null)) {
      for (var aturan in _aturanList) {
        print(aturan);
        bool aturanTerpenuhi = true;

        for (var gejalaId in aturan['gejala']) {
          int gejalaIndex = _gejalaList.indexWhere((gejala) => gejala['gejalaId'] == gejalaId);

          if (gejalaIndex >= 0 && !_answers[gejalaIndex]!) {
            aturanTerpenuhi = false;
            break;
          }
        }

        if (aturanTerpenuhi) {
          String hasilId = aturan['hasilId'];
          QuerySnapshot hasilSnapshot = await FirebaseFirestore.instance.collection('master_data_diagnosa').where('kode_hasil', isEqualTo: hasilId).get();

          if (hasilSnapshot.docs.isNotEmpty) {
            hasilDiagnosa = "${hasilSnapshot.docs.first['nama_hasil']}";
            saranDiagnosa = "${hasilSnapshot.docs.first['saran_hasil']}";
            kodeWarna = _parseColor(hasilSnapshot.docs.first['kode_warna'] ?? '');
          }
          break;
        }
      }

      double bobot = 0;

      List<Map<String, dynamic>>  pertanyaan= _gejalaList.map((gejala) {
        if(_answers[_gejalaList.indexOf(gejala)] == true){
          bobot = bobot + (gejala['bobot'] ?? 0).toDouble();
        }
        return {
          'pertanyaan': gejala['pertanyaan'],
          'jawaban': _answers[_gejalaList.indexOf(gejala)] == true ? "Ya" : "Tidak",
        };
      }).toList();

      bobotDiagnosa = '${bobot} %';

      // Simpan hasil diagnosa ke Firebase Firestore
      // DiagnosaData diagnosaData = DiagnosaData(
      //   userName: widget.name,
      //   email: widget.email,
      //   tanggalDiagnosa: DateTime.now(),
      //   penyakit: widget.penyakit,
      //   hasil: hasilDiagnosa,
      //   answerList: _gejalaList.map((gejala) {
      //     if(_answers[_gejalaList.indexOf(gejala)] == true){
      //       bobot = bobot + (gejala['bobot'] ?? 0).toDouble();
      //     }
      //     return {
      //       'pertanyaan': gejala['pertanyaan'],
      //       'jawaban': _answers[_gejalaList.indexOf(gejala)] == true ? "Ya" : "Tidak",
      //     };
      //   }).toList(),
      // );

      DiagnosaData diagnosaData = DiagnosaData(
        userName: widget.name,
        email: widget.email,
        tanggalDiagnosa: DateTime.now(),
        penyakit: widget.penyakit,
        hasil: hasilDiagnosa,
        bobot : bobotDiagnosa,
        saran: saranDiagnosa,
        answerList: pertanyaan
      );

      _saveDiagnosaToFirestore(diagnosaData);
    }

    setState(() {
      _hasilDiagnosa = hasilDiagnosa;
      _bobotDiagnosa = bobotDiagnosa;
      _saranDiagnosa = saranDiagnosa;
      _kodeWarna = kodeWarna;
      _showLabel = false; // Setel _showLabel menjadi false setelah hasil diagnosa ditemukan.
    });
  }

  void _resetDiagnosa() {
    setState(() {
      _currentQuestionIndex = 0;
      _hasilDiagnosa = '';
      _saranDiagnosa = '';
      _bobotDiagnosa ='';
      _initializeAnswers();
      _showLabel = true; // Setel _showLabel menjadi true ketika pengguna ingin mengulangi diagnosa.
    });
  }

  void _saveDiagnosaToFirestore(DiagnosaData diagnosaData) async {
    CollectionReference diagnosaCollection = FirebaseFirestore.instance.collection('riwayat_diagnosa');

    await diagnosaCollection.add({
      'user_name': diagnosaData.userName,
      'email': diagnosaData.email,
      'tanggal_diagnosa': diagnosaData.tanggalDiagnosa,
      'penyakit': diagnosaData.penyakit,
      'hasil': diagnosaData.hasil,
      'saran':diagnosaData.saran,
      'bobot':diagnosaData.bobot,
      'answer_list': diagnosaData.answerList,
    });
  }

  Color _parseColor(String colorString) {
    // Implementasi fungsi untuk mengonversi string warna (format hex) menjadi objek Color
    if (colorString != null && colorString.isNotEmpty && colorString.length == 7 && colorString[0] == '#') {
      try {
        int value = int.parse(colorString.substring(1), radix: 16);
        return Color(value + 0xFF000000); // Tambahkan alpha channel 255
      } catch (e) {
        print('Error parsing color: $e');
      }
    }
    return Colors.white; // Warna default jika string tidak valid atau kosong
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diagnosa ${widget.penyakit}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _showLabel
                ? Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.blue.shade900, // Atur warna latar belakang
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline, // Tambahkan ikon di sini
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Hai ${widget.name} !',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Atur warna teks
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Untuk mendiagnosa penyakit ${widget.penyakit} Anda, silakan jawab pertanyaan berikut :',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Atur warna teks
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
                : const SizedBox(), // Menampilkan atau menyembunyikan label berdasarkan nilai _showLabel.
            _currentQuestionIndex < _gejalaList.length
                ? _buildQuestionCard(_gejalaList[_currentQuestionIndex])
                : const SizedBox(),
            const SizedBox(height: 20),
            _hasilDiagnosa.isNotEmpty
                ? Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: _kodeWarna, // Atur warna latar belakang
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_outline, // Tambahkan ikon di sini
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Hasil Diagnosa:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white, // Atur warna teks
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _hasilDiagnosa,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white, // Atur warna teks
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Saran:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white, // Atur warna teks
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _saranDiagnosa,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white, // Atur warna teks
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Persentasi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white, // Atur warna teks
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _bobotDiagnosa,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white, // Atur warna teks
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _resetDiagnosa,
                      child: const Text('Ulangi Diagnosa'),
                    ),
                  ],
                ),
              ),
            )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
