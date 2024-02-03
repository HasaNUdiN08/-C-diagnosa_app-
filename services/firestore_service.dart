
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diagnosa_data.dart';

class FirestoreService {
  final CollectionReference jawabanListCollection =
  FirebaseFirestore.instance.collection('jawaban_list');


  Future<List<Map<String, dynamic>>> getJawabanList(String penyakit) async {
    QuerySnapshot querySnapshot = await jawabanListCollection
        .where('Penyakit',  isEqualTo: penyakit)
        .orderBy('Nomor', descending: false)
        .get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  final CollectionReference diagnosaCollection =
  FirebaseFirestore.instance.collection('riwayat_diagnosa');

  Future<void> saveDiagnosa(DiagnosaData diagnosaData) async {
    await diagnosaCollection.add({
      'user_name': diagnosaData.userName,
      'email':diagnosaData.email,
      'tanggal_diagnosa': diagnosaData.tanggalDiagnosa,
      'penyakit': diagnosaData.penyakit,
      'hasil': diagnosaData.hasil,
      'answer_list': diagnosaData.answerList.map((answer) {
        return {
          'pertanyaan': answer['pertanyaan'],
          'jawaban': answer['jawaban'],
        };
      }).toList(),
    });
  }

  Future<List<Map<String, dynamic>>> getDiagnosaHistoryByPenyakit(String penyakit) async {
    // Assuming 'diagnosaCollection' is your Firestore collection reference
    var query = await diagnosaCollection
        .where('penyakit', isEqualTo: penyakit)
        .orderBy('tanggal_diagnosa', descending: true) // Adjust the order based on your needs
        .get();

    return query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}

