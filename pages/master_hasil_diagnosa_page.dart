import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MasterHasilDiagnosaPage extends StatefulWidget {
  final String penyakit;

  MasterHasilDiagnosaPage({required this.penyakit});
  @override
  _MasterHasilDiagnosaPageState createState() => _MasterHasilDiagnosaPageState();
}

class _MasterHasilDiagnosaPageState extends State<MasterHasilDiagnosaPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _kodeController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _saranController = TextEditingController();
  final TextEditingController _kodeWarnaController = TextEditingController(); // Tambahkan controller untuk kode warna

  List<DocumentSnapshot> _masterDataDiagnosaList = [];

  @override
  void initState() {
    super.initState();
    _loadMasterDataDiagnosa();
  }

  void _loadMasterDataDiagnosa() async {
    QuerySnapshot masterDataDiagnosaSnapshot = await _firestore
        .collection('master_data_diagnosa')
        .where('penyakit', isEqualTo: widget.penyakit)
        .get();
    setState(() {
      _masterDataDiagnosaList = masterDataDiagnosaSnapshot.docs;
    });
  }

  void _addMasterDataDiagnosa() async {
    await _firestore.collection('master_data_diagnosa').add({
      'penyakit': widget.penyakit,
      'kode_hasil': _kodeController.text,
      'nama_hasil': _namaController.text,
      'saran_hasil': _saranController.text,
      'kode_warna': _kodeWarnaController.text, // Simpan kode warna ke Firestore
    });

    _loadMasterDataDiagnosa();
    _kodeController.clear();
    _namaController.clear();
    _saranController.clear();
    _kodeWarnaController.clear(); // Kosongkan input kode warna juga
  }

  void _updateMasterDataDiagnosa(
      String masterDataDiagnosaId, String updatedKode, String updatedNama, String updatedSaran, String updatedKodeWarna) async {
    await _firestore.collection('master_data_diagnosa').doc(masterDataDiagnosaId).update({
      'penyakit': widget.penyakit,
      'kode_hasil': updatedKode,
      'nama_hasil': updatedNama,
      'saran_hasil': updatedSaran,
      'kode_warna': updatedKodeWarna, // Simpan kode warna ke Firestore
    });

    _loadMasterDataDiagnosa();
  }

  void _deleteMasterDataDiagnosa(String masterDataDiagnosaId) async {
    await _firestore.collection('master_data_diagnosa').doc(masterDataDiagnosaId).delete();

    _loadMasterDataDiagnosa();
  }

  void _editMasterDataDiagnosa(DocumentSnapshot masterDataDiagnosa) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditMasterDataDiagnosaPage(
          masterDataDiagnosa: masterDataDiagnosa,
          onUpdate: _updateMasterDataDiagnosa,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Master Data Diagnosa - ${widget.penyakit}'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _kodeController,
                  decoration: const InputDecoration(
                    labelText: 'Kode Hasil',
                  ),
                ),
                TextField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Hasil',
                  ),
                ),
                TextField(
                  controller: _saranController,
                  decoration: const InputDecoration(
                    labelText: 'Saran Hasil',
                  ),
                ),
                TextField(
                  controller: _kodeWarnaController, // Tambahkan input untuk kode warna
                  decoration: const InputDecoration(
                    labelText: 'Kode Warna',
                  ),
                ),
                ElevatedButton(
                  onPressed: _addMasterDataDiagnosa,
                  child: const Text('Tambah Master Data Diagnosa'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _masterDataDiagnosaList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot masterDataDiagnosa = _masterDataDiagnosaList[index];
                String masterDataDiagnosaId = masterDataDiagnosa.id;
                String kodeHasil = masterDataDiagnosa['kode_hasil'] ?? '';
                String namaHasil = masterDataDiagnosa['nama_hasil'] ?? '';
                String saranHasil = masterDataDiagnosa['saran_hasil'] ?? '';
                String kodeWarna = masterDataDiagnosa['kode_warna'] ?? ''; // Ambil kode warna dari Firestore

                return ListTile(
                  title: Text('Kode: $kodeHasil, Nama: $namaHasil, Saran: $saranHasil, Kode Warna: $kodeWarna'), // Tampilkan kode warna
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _editMasterDataDiagnosa(masterDataDiagnosa);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // Konfirmasi dan hapus master data diagnosa
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Hapus Master Data Diagnosa'),
                                content: const Text('Anda yakin ingin menghapus master data diagnosa ini?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteMasterDataDiagnosa(masterDataDiagnosaId);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EditMasterDataDiagnosaPage extends StatefulWidget {
  final DocumentSnapshot masterDataDiagnosa;
  final Function(String, String, String, String, String) onUpdate;

  EditMasterDataDiagnosaPage({required this.masterDataDiagnosa, required this.onUpdate});

  @override
  _EditMasterDataDiagnosaPageState createState() => _EditMasterDataDiagnosaPageState();
}

class _EditMasterDataDiagnosaPageState extends State<EditMasterDataDiagnosaPage> {
  TextEditingController _kodeController = TextEditingController();
  TextEditingController _namaController = TextEditingController();
  TextEditingController _saranController = TextEditingController();
  TextEditingController _kodeWarnaController = TextEditingController(); // Tambahkan controller untuk kode warna

  @override
  void initState() {
    super.initState();
    _kodeController.text = widget.masterDataDiagnosa['kode_hasil'] ?? '';
    _namaController.text = widget.masterDataDiagnosa['nama_hasil'] ?? '';
    _saranController.text = widget.masterDataDiagnosa['saran_hasil'] ?? '';
    _kodeWarnaController.text = widget.masterDataDiagnosa['kode_warna'] ?? ''; // Isi input kode warna dari Firestore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Master Data Diagnosa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _kodeController,
              decoration: const InputDecoration(
                labelText: 'Kode Hasil',
              ),
            ),
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Hasil',
              ),
            ),
            TextField(
              controller: _saranController,
              decoration: const InputDecoration(
                labelText: 'Saran Hasil',
              ),
            ),
            TextField(
              controller: _kodeWarnaController, // Tambahkan input untuk kode warna
              decoration: const InputDecoration(
                labelText: 'Kode Warna',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onUpdate(
                  widget.masterDataDiagnosa.id,
                  _kodeController.text,
                  _namaController.text,
                  _saranController.text,
                  _kodeWarnaController.text,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
