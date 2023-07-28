import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditStudent extends StatefulWidget {
  final DocumentSnapshot? documentSnapshot;

  const EditStudent({Key? key, this.documentSnapshot}) : super(key: key);

  @override
  State<EditStudent> createState() => _EditStudentState();
}

class _EditStudentState extends State<EditStudent> {
  final CollectionReference _students =
      FirebaseFirestore.instance.collection('students');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _angkatanController = TextEditingController();

  String imageUrl = '';

  void initState() {
      super.initState();
      if (widget.documentSnapshot != null) {
      _nameController.text = widget.documentSnapshot!['name'];
      _nimController.text = widget.documentSnapshot!['nim'];
      _angkatanController.text = widget.documentSnapshot!['angkatan'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  '\n\nEDIT',
                  style: TextStyle(
                      fontSize: 50,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 50.0,
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextField(
                controller: _nimController,
                decoration: InputDecoration(labelText: 'NIM'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextField(
                controller: _angkatanController,
                decoration: InputDecoration(labelText: 'Angkatan'),
                inputFormatters: [
                  FilteringTextInputFormatter
                      .digitsOnly // Hanya menerima input angka
                ],
                keyboardType: TextInputType.number, // Keyboard tipe angka
              ),
              const SizedBox(
                height: 20.0,
              ),
              const SizedBox(
                height: 20.0,
              ),
              ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text('Update Data'),
              onPressed: () async {
                final String name = _nameController.text;
                final String nim = _nimController.text;
                final String angkatan = _angkatanController.text;

                if (name != "" && widget.documentSnapshot != null) {
                  await _students.doc(widget.documentSnapshot!.id).update({
                    "name": name,
                    "nim": nim,
                    "angkatan": angkatan
                  });
                  _nameController.text = '';
                  _nimController.text = '';
                  _angkatanController.text = '';
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Data berhasil diubah'))
                );
                Navigator.pop(context);
              },
            ),
            ],
          ),
        ),
      ),
    );
  }
}
