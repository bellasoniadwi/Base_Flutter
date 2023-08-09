import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

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

  String imageUrl = '';

  void initState() {
      super.initState();
      if (widget.documentSnapshot != null) {
      _nameController.text = widget.documentSnapshot!['name'];
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

                if (name != "" && widget.documentSnapshot != null) {
                  await _students.doc(widget.documentSnapshot!.id).update({
                    "name": name,
                    "timestamps": FieldValue.serverTimestamp(),
                  });
                  _nameController.text = '';
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
