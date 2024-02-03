import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MasterGejalaPage extends StatefulWidget {
  final String penyakit;
  MasterGejalaPage({required this.penyakit});
  @override
  _MasterGejalaPageState createState() => _MasterGejalaPageState();
}

class _MasterGejalaPageState extends State<MasterGejalaPage> {
  final TextEditingController gejalaIdController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController pertanyaanController = TextEditingController();
  final TextEditingController bobotController = TextEditingController(); // Tambahkan controller untuk bobot

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Gejala'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: gejalaIdController,
                  decoration: const InputDecoration(
                    labelText: 'Gejala ID',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Gejala',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: pertanyaanController,
                  decoration: const InputDecoration(
                    labelText: 'Pertanyaan',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: bobotController, // Gunakan controller untuk bobot
                  decoration: const InputDecoration(
                    labelText: 'Bobot (Decimal)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // Simpan atau update gejala ke Firestore
                    String gejalaId = gejalaIdController.text;
                    String namaGejala = namaController.text;
                    String pertanyaan = pertanyaanController.text;
                    double bobot = double.tryParse(bobotController.text) ?? 0.0; // Ambil nilai bobot sebagai double

                    if (gejalaId.isNotEmpty && namaGejala.isNotEmpty && pertanyaan.isNotEmpty) {
                      try {
                        // Periksa apakah gejala dengan Gejala ID yang sama sudah ada
                        DocumentSnapshot existingGejala = await firestore.collection('master_gejala').doc(gejalaId).get();

                        if (existingGejala.exists) {
                          // Jika sudah ada, update gejala yang ada
                          await firestore.collection('master_gejala').doc(gejalaId).update({
                            'penyakit': widget.penyakit,
                            'nama': namaGejala,
                            'pertanyaan': pertanyaan,
                            'bobot': bobot, // Simpan bobot ke Firestore
                          });
                        } else {
                          // Jika belum ada, tambahkan gejala baru
                          await firestore.collection('master_gejala').doc(gejalaId).set({
                            'penyakit': widget.penyakit,
                            'gejalaId': gejalaId,
                            'nama': namaGejala,
                            'pertanyaan': pertanyaan,
                            'bobot': bobot, // Simpan bobot ke Firestore
                          });
                        }

                        // Setelah gejala berhasil disimpan atau diperbarui, kosongkan input fields
                        _clearInputFields();
                      } catch (e) {
                        print('Error: $e');
                        _showErrorDialog('Terjadi kesalahan saat menyimpan gejala.');
                      }
                    } else {
                      _showErrorDialog('Pastikan semua input diisi dengan benar.');
                    }
                  },
                  child: Text('Simpan Gejala'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _buildGejalaList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGejalaList() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('master_gejala').where('penyakit', isEqualTo: widget.penyakit).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        var gejalaList = snapshot.data!.docs;

        return ListView.builder(
          itemCount: gejalaList.length,
          itemBuilder: (context, index) {
            var gejala = gejalaList[index];
            String gejalaId = gejala['gejalaId'];
            String nama = gejala['nama'];
            String pertanyaan = gejala['pertanyaan'];
            double bobot = (gejala['bobot'] ?? 0).toDouble(); // Ambil nilai bobot dari Firestore

            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: Text('Gejala ID: $gejalaId'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nama Gejala: $nama'),
                    Text('Pertanyaan: $pertanyaan'),
                    Text('Bobot: $bobot'), // Tampilkan bobot
                  ],
                ),
                onTap: () {
                  // Isi input fields dengan data gejala yang ada untuk diperbarui
                  gejalaIdController.text = gejalaId;
                  namaController.text = nama;
                  pertanyaanController.text = pertanyaan;
                  bobotController.text = bobot.toString(); // Isi input bobot dengan nilai dari Firestore
                },
                onLongPress: () {
                  // Hapus gejala saat ini dari Firestore
                  _showDeleteDialog(gejalaId);
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // Hapus gejala saat ini dari Firestore
                    _showDeleteDialog(gejalaId);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteDialog(String gejalaId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus gejala ini?'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Hapus gejala dari Firestore
                await firestore.collection('master_gejala').doc(gejalaId).delete();
                Navigator.of(context).pop();
                _clearInputFields();
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _clearInputFields() {
    gejalaIdController.clear();
    namaController.clear();
    pertanyaanController.clear();
    bobotController.clear(); // Kosongkan input bobot juga
  }

  Future<void> _showErrorDialog(String message) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
