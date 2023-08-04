import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:project_sinarindo/models/user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddStudent extends StatefulWidget {
  const AddStudent({Key? key}) : super(key: key);

  @override
  State<AddStudent> createState() => _AddStudent();
}

class _AddStudent extends State<AddStudent> {
  final CollectionReference _students =
      FirebaseFirestore.instance.collection('students');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _angkatanController = TextEditingController();
  final TextEditingController _pelatihController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String imageUrl = '';
  String _imagePath = '';

  // Fungsi Pick Image dan Penyimpanan ke Firebase
  Future<void> _pickAndSetImage(Function(String) setImageUrl) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.camera);
    if (file == null) return;
    setState(() {
      _imagePath = file.path;
    });
    Uint8List imageBytes = await file.readAsBytes();
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceImageToUpload = FirebaseStorage.instance.ref().child('images/$uniqueFileName.jpg');
    await referenceImageToUpload.putData(imageBytes);

    String imageUrl = await referenceImageToUpload.getDownloadURL();
    setImageUrl(imageUrl);
  }

  // Fungsi Pembantu Image untuk mengatur imageUrl dengan menggunakan setState.
  void _setImageUrl(String imageUrl) {
    setState(() {
      this.imageUrl = imageUrl;
    });
  }

  // Komponen Pengambilan Lokasi Saat Ini
  Position? _currentLocation;
  late bool servicePermission = false;
  late LocationPermission permission;
  Future<Position> _getCurrentLocation() async {
    // check if we have permission to access location service
    servicePermission = await Geolocator.isLocationServiceEnabled();
    if (!servicePermission) {
      print("Service Disabled");
    }
    // service enabled
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return await Geolocator.getCurrentPosition();
  }

  void initState() {
    super.initState();
    fetchUserDataFromFirestore();
  }

  Future<void> fetchUserDataFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var userDoc =  await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          String name = userDoc.data()?['name'] ?? '';
          String email = userDoc.data()?['email'] ?? '';
          String pelatih = userDoc.data()?['didaftarkan_oleh'] ?? '';
          _nameController.text = name;
          _pelatihController.text = pelatih;
          Provider.of<UserData>(context, listen: false).updateUserData(name, email, pelatih);
        }
      }
    } catch (error) {
      print("Error fetching user data: $error");
    }
  }

  //Membuat pilihan dropdown kehadiran
  // Initial Selected Value
  String dropdownvalue = 'Masukkan Keterangan';
  // List of items in our dropdown menu
  var items = [
    'Masukkan Keterangan',
    'Masuk',
    'Izin',
    'Sakit',
  ];

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
                  '\n\nCREATE',
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
                enabled: false,
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
              TextField(
                controller: _pelatihController,
                decoration: InputDecoration(labelText: 'Pelatih'),
                enabled: false,
              ),
              const SizedBox(
                height: 20.0,
              ),
              DropdownButton<String?>(
                // Initial Value
                value: dropdownvalue,

                // Down Arrow Icon
                icon: const Icon(Icons.keyboard_arrow_down),

                // Array list of items
                items: items.map<DropdownMenuItem<String?>>((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(), // After selecting the desired option,it will
                // change button value to selected value
                onChanged: (value) {
                  setState(() {
                    dropdownvalue = value!;
                  });
                },
              ),
              const SizedBox(
                height: 20.0,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepPurple,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () => _pickAndSetImage(_setImageUrl),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt,
                        color: Colors.white), // Icon added here
                    SizedBox(
                        width:
                            10), // Add some spacing between the icon and text
                    Text(
                      'Ambil Foto',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              // IconButton(onPressed: () => _pickAndSetImage(_setImageUrl), icon: Icon(Icons.camera_alt), color: Colors.deepPurple,),
              const SizedBox(
                height: 20.0,
              ),
              _imagePath != '' ? Image.file(File(_imagePath)) : Container(),
              const SizedBox(
                height: 20.0,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text('Simpan Data'),
                onPressed: () async {
                  final String name = _nameController.text;
                  final String nim = _nimController.text;
                  final String angkatan = _angkatanController.text;
                  final String keterangan = dropdownvalue;
                  final String pelatih = _pelatihController.text;

                  // Get current latitude and longitude
                  _currentLocation = await _getCurrentLocation();
                  final String latitude = _currentLocation!.latitude.toString();
                  final String longitude =
                      _currentLocation!.longitude.toString();

                  if (imageUrl.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please Upload an Image')));
                    return;
                  }
                  if (name != "") {
                    await _students.add({
                      "name": name,
                      "nim": nim,
                      "angkatan": angkatan,
                      "timestamps": FieldValue.serverTimestamp(),
                      "image": imageUrl,
                      "latitude": latitude,
                      "longitude": longitude,
                      "keterangan": keterangan,
                      "pelatih": pelatih,
                    });
                    _nameController.text = '';
                    _nimController.text = '';
                    _angkatanController.text = '';
                    _pelatihController.text = '';
                    dropdownvalue = '';
                    imageUrl = '';
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Data berhasil ditambahkan')));
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
