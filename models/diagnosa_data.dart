class DiagnosaData {
  final String userName;
  final String email;
  final DateTime tanggalDiagnosa;
  final String penyakit;
  final String hasil;
  final String saran;
  final String bobot;
  final List<Map<String, dynamic>> answerList;

  DiagnosaData({
    required this.userName,
    required this.email,
    required this.tanggalDiagnosa,
    required this.penyakit,
    required this.hasil,
    required this.saran,
    required this.bobot,
    required this.answerList,
  });
}