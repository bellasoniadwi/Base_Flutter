import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_sinarindo/screens/base_screen.dart';
import 'package:provider/provider.dart';
import 'package:project_sinarindo/models/user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AddStudent extends StatefulWidget {
  const AddStudent({Key? key}) : super(key: key);

  @override
  State<AddStudent> createState() => _AddStudent();
}

class _AddStudent extends State<AddStudent> {
  final CollectionReference _students =
      FirebaseFirestore.instance.collection('students');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pelatihController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String imageUrl = '';
  String _imagePath = '';
  bool _isSaving = false;

  String? _selectedValue;
  List<String> listOfValue = ['Masuk', 'Izin', 'Sakit'];

  // Fungsi Pick Image tanpa menyimpan ke Firebase
  Future<void> _pickAndSetImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.camera);
    if (file == null) return;
    setState(() {
      _imagePath = file.path;
    });
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
          String image = userDoc.data()?['image'] ?? '';
          String nomor_induk = userDoc.data()?['nomor_induk'] ?? '';
          String angkatan = userDoc.data()?['angkatan'] ?? '';
          _nameController.text = name;
          _pelatihController.text = pelatih;
          Provider.of<UserData>(context, listen: false).updateUserData(name, email, pelatih, image, nomor_induk, angkatan);
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
                  '\n\nFORM ABSENSI',
                  style: TextStyle(
                      fontSize: 50,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 50.0,
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Masukkan Nama',
                    labelText: 'NAMA',
                ),
                enabled: false,
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextField(
                controller: _pelatihController,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Masukkan Pelatih',
                    labelText: 'PELATIH',
                ),
                enabled: false,
              ),
              const SizedBox(
                height: 20.0,
              ),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                ),
                value: _selectedValue,
                hint: Text(
                  'Pilih Keterangan',
                ),
                isExpanded: true,
                onChanged: (value) {
                  setState(() {
                    _selectedValue = value as String?;
                  });
                },
                onSaved: (value) {
                  setState(() {
                    _selectedValue = value as String?;
                  });
                },
                items: listOfValue.map((String val) {
                  return DropdownMenuItem(
                    value: val,
                    child: Text(
                      val,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 20.0,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.blueAccent,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(4), // Atur sesuai kebutuhan
                  ),
                ),
                onPressed: () => _pickAndSetImage(),
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
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              if (_imagePath.isNotEmpty)
                Center(
                  child: Container(
                    height: 350,
                    width: 200,
                    child: _imagePath != ''
                        ? Image.file(
                            File(_imagePath),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
              const SizedBox(
                height: 10.0,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.blueAccent,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(4), // Atur sesuai kebutuhan
                  ),
                ),
                child: _isSaving
                ? CircularProgressIndicator( // Tampilkan indikator loading
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  )
                : Text(
                    'Simpan Data',
                    style: TextStyle(
                        color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  ),
                onPressed: _isSaving // Prevent button press when loading
                      ? null // Button is disabled when loading
                      : () async {
                  setState(() {
                    _isSaving = true; // Aktifkan indikator loading
                  });

                  final String name = _nameController.text;
                  final String keterangan = _selectedValue.toString();
                  final String pelatih = _pelatihController.text;

                  // Get current latitude and longitude
                  _currentLocation = await _getCurrentLocation();
                  final String latitude = _currentLocation!.latitude.toString();
                  final String longitude =
                      _currentLocation!.longitude.toString();

                  if (_imagePath.isEmpty) { // Ganti imageUrl.isEmpty menjadi _imagePath.isEmpty
                      setState(() {
                        _isSaving = false; // Matikan indikator loading setelah selesai
                      });
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Upload Foto Absen Anda'),
                        backgroundColor: Colors.blueAccent,));
                    return;
                  }

                  if (keterangan == "Masuk" || keterangan=="Izin" || keterangan=="Sakit") {
                    Uint8List imageBytes = await File(_imagePath).readAsBytes();
                    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
                    String formattedDateTime = DateFormat('yyyy-MM-dd').format(DateTime.now());

                    String fileName = 'images/' + uniqueFileName + '_' + formattedDateTime + '.jpg';
                    Reference referenceImageToUpload = FirebaseStorage.instance.ref().child(fileName);
                    await referenceImageToUpload.putData(imageBytes);

                    String imageUrl = await referenceImageToUpload.getDownloadURL();

                    // Generate custom id : increment
                    String docId = DateTime.now().millisecondsSinceEpoch.toString();
                    // Create a reference to the document using the custom ID
                    DocumentReference documentReference = _students.doc(docId);

                    await documentReference.set({
                      "name": name,
                      "timestamps": FieldValue.serverTimestamp(),
                      "image": imageUrl,
                      "latitude": latitude,
                      "longitude": longitude,
                      "keterangan": keterangan,
                      "instruktur": pelatih,
                    });

                    setState(() {
                      _isSaving = false; // Matikan indikator loading setelah selesai
                    });

                    _nameController.text = '';
                    _pelatihController.text = '';
                    dropdownvalue = '';
                    _imagePath  = '';

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Data Absensi anda berhasil tersimpan'),
                          backgroundColor: Colors.blueAccent,
                        ));
                  Navigator.pop(context);
                  } else {
                    setState(() {
                      _isSaving = false; // Matikan indikator loading setelah selesai
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Masukkan keterangan kehadiran'),
                    backgroundColor: Colors.blueAccent,));
                  }
                },
              ),
              const SizedBox(
                height: 80.0,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BaseScreen()),
          ).then((data) {});
        },
        child: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
