
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MasterAturanGejalaPage extends StatefulWidget {
  final String penyakit;
  MasterAturanGejalaPage({required this.penyakit});
  @override
  _MasterAturanGejalaPageState createState() => _MasterAturanGejalaPageState();
}

class _MasterAturanGejalaPageState extends State<MasterAturanGejalaPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController hasilController = TextEditingController();
  final TextEditingController noController = TextEditingController(); // New controller for 'no' field

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Set<String> selectedGejala = {};
  String? selectedAturanId;
  bool isEditing = false;
  List<String> masterHasilList = [];

  @override
  void initState() {
    super.initState();
    _loadMasterHasilList();
  }

  void _loadMasterHasilList() async {
    final QuerySnapshot hasilSnapshot = await firestore
        .collection('master_data_diagnosa')
        .where('penyakit', isEqualTo: widget.penyakit)
        .get();

    final Set<String> uniqueHasilList = Set<String>();

    hasilSnapshot.docs.forEach((doc) {
      uniqueHasilList.add(doc['kode_hasil'].toString());
    });

    setState(() {
      masterHasilList = uniqueHasilList.toList();
      hasilController.text = masterHasilList.isNotEmpty ? masterHasilList[0] : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Aturan' : 'Tambah Aturan'),
      ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField( // TextField for 'no'
                    controller: noController,
                    decoration: const InputDecoration(
                      labelText: 'No',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Aturan',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final selectedGejalaList =
                      await _showGejalaSelectionDialog(context);
                      if (selectedGejalaList != null) {
                        setState(() {
                          selectedGejala = selectedGejalaList;
                        });
                      }
                    },
                    child: const Text('Pilih Gejala'),
                  ),
                  const SizedBox(height: 10),
                  _buildDropdownFormField(),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (isEditing) {
                        await _updateAturan();
                      } else {
                        await _addAturan();
                      }
                    },
                    child: Text(isEditing ? 'Simpan Perubahan' : 'Simpan Aturan'),
                  ),
                ],
              ),
            ),
            ///
            const Divider(),
            Expanded(
              child: _buildAturanList(),
            ),
          ],
      ),
    );
  }

  Widget _buildDropdownFormField() {
    return DropdownButtonFormField<String>(
      value: hasilController.text.isNotEmpty ? hasilController.text : null,
      items: masterHasilList.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          hasilController.text = newValue ?? '';
        });
      },
      decoration: const InputDecoration(
        labelText: 'HasilId',
        border: OutlineInputBorder(),
      ),
      hint: const Text('Pilih Hasil'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Pilih hasil';
        }
        return null;
      },
    );
  }

  Widget _buildAturanList() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('master_aturan_gejala')
          .where('penyakit',isEqualTo: widget.penyakit)
          .orderBy('no', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        var aturanList = snapshot.data!.docs;

        return ListView.builder(
          itemCount: aturanList.length,
          itemBuilder: (context, index) {
            var aturan = aturanList[index];
            String no = aturan['no'];
            String nama = aturan['nama'];
            List<String> gejalaList = List<String>.from(aturan['gejala']);
            String hasilId = aturan['hasilId'];

            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: Text('[ No: ${no} ] Nama Aturan: $nama'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gejala: ${gejalaList.join(', ')}'),
                    Text('HasilId: $hasilId'),
                  ],
                ),
                onTap: () {
                  // Isi input fields dengan data aturan yang ada untuk diedit
                  setState(() {
                    selectedAturanId = aturan.id;
                    namaController.text = nama;
                    selectedGejala = Set<String>.from(gejalaList); // Menggunakan Set
                    hasilController.text = hasilId;
                    noController.text = no;
                    isEditing = true;
                  });
                },
                onLongPress: () {
                  // Hapus aturan saat ini dari Firestore
                  _showDeleteDialog(aturan.id);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Hapus aturan saat ini dari Firestore
                    _showDeleteDialog(aturan.id);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addAturan() async {
    String namaAturan = namaController.text;
    String hasilId = hasilController.text;
    String no = noController.text;

    if (namaAturan.isNotEmpty && selectedGejala.isNotEmpty && hasilId.isNotEmpty) {
      try {
        await firestore.collection('master_aturan_gejala').add({
          'penyakit': widget.penyakit,
          'nama': namaAturan,
          'gejala': selectedGejala.toList(),
          'hasilId': hasilId,
          'no': no, // Add the 'no' field
        });
        _clearInputFields();
      } catch (e) {
        print('Error: $e');
        _showErrorDialog('Terjadi kesalahan saat menyimpan aturan.');
      }
    } else {
      _showErrorDialog('Pastikan semua input diisi dengan benar.');
    }
  }

  Future<void> _updateAturan() async {
    if (selectedAturanId != null) {
      String namaAturan = namaController.text;
      String hasilId = hasilController.text;
      String no = noController.text ;

      if (namaAturan.isNotEmpty && selectedGejala.isNotEmpty && hasilId.isNotEmpty) {
        try {
          await firestore.collection('master_aturan_gejala').doc(selectedAturanId).update({
            'penyakit': widget.penyakit,
            'nama': namaAturan,
            'gejala': selectedGejala.toList(),
            'hasilId': hasilId,
            'no': no,
          });
          _clearInputFields();
          setState(() {
            selectedAturanId = null;
            isEditing = false;
          });
        } catch (e) {
          print('Error: $e');
          _showErrorDialog('Terjadi kesalahan saat memperbarui aturan.');
        }
      } else {
        _showErrorDialog('Pastikan semua input diisi dengan benar.');
      }
    }
  }

  Future<void> _showDeleteDialog(String aturanId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus aturan ini?'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Hapus aturan dari Firestore
                await firestore.collection('master_aturan_gejala').doc(aturanId).delete();
                Navigator.of(context).pop();
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _clearInputFields() {
    namaController.clear();
    hasilController.clear();
    noController.clear();
    selectedGejala.clear();
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

  Future<Set<String>?> _showGejalaSelectionDialog(BuildContext context) async {
    final gejalaCollection = firestore.collection('master_gejala');
    final gejalaDocs = await gejalaCollection.where("penyakit" ,isEqualTo: widget.penyakit).get();

    List<String> availableGejala = [];

    gejalaDocs.docs.forEach((doc) {
      availableGejala.add(doc['gejalaId']);
    });

    Set<String>? selectedGejala = Set<String>();
    selectedGejala = await showDialog<Set<String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Gejala'),
          content: MultiSelectChip(
            gejalaList: availableGejala,
            selectedGejala: selectedGejala,
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop<Set<String>>(selectedGejala ?? {});
              },
              child: const Text('Pilih'),
            ),
          ],
        );
      },
    );

    if (selectedGejala != null) {
      setState(() {
        this.selectedGejala = selectedGejala!;
      });
    }

    return selectedGejala;
  }
}

class MultiSelectChip extends StatefulWidget {
  final List<String> gejalaList;
  final Set<String>? selectedGejala;

  MultiSelectChip({required this.gejalaList, this.selectedGejala});

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  Set<String> selectedChipList = {};

  @override
  void initState() {
    super.initState();
    if (widget.selectedGejala != null) {
      selectedChipList.addAll(widget.selectedGejala!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: widget.gejalaList.map((String gejala) {
        return ChoiceChip(
          label: Text(gejala),
          selected: selectedChipList.contains(gejala),
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                selectedChipList.add(gejala);
              } else {
                selectedChipList.remove(gejala);
              }
              widget.selectedGejala?.clear();
              widget.selectedGejala?.addAll(selectedChipList);
            });
          },
        );
      }).toList(),
    );
  }
}
