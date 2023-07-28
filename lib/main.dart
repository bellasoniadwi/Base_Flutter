import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

// Fungsi Pick Image dan Penyimpanan ke Firebase
Future<void> _pickAndSetImage(Function(String) setImageUrl) async {
  ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: ImageSource.camera);

  if (file == null) return;

  // Mengubah gambar menjadi format yang lebih efisien untuk disimpan di Firebase Storage
  Uint8List imageBytes = await file.readAsBytes();
  String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
  Reference referenceImageToUpload = FirebaseStorage.instance.ref().child('images/$uniqueFileName.jpg');
  await referenceImageToUpload.putData(imageBytes);

  String imageUrl = await referenceImageToUpload.getDownloadURL();
  setImageUrl(imageUrl);
}

class _HomePageState extends State<HomePage> {
  // Mendefinisikan variabel
  final CollectionReference _students = FirebaseFirestore.instance.collection('students');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _angkatanController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String imageUrl='';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(),
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: StreamBuilder(
        stream: _students.snapshots(), //build connection
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length, //number of rows
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: ClipOval(
                      child: Image.network(
                        documentSnapshot['image'],
                        width: 50, // Sesuaikan ukuran gambar sesuai kebutuhan Anda
                        height: 50, // Sesuaikan ukuran gambar sesuai kebutuhan Anda
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(documentSnapshot['name']),
                    subtitle: Text(_getFormattedTimestamp(documentSnapshot['timestamps'])),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _update(documentSnapshot)),
                          IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _delete(documentSnapshot.id)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }


  // Komponen Utama Fungsi CRUD
  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _nameController.text = documentSnapshot['name'];
      _nimController.text = documentSnapshot['nim'];
      _angkatanController.text = documentSnapshot['angkatan'];
      // keperluan update
      Timestamp tanggalTimestamp = documentSnapshot['tanggal']; //mengambil objek timestamp dari firebase
      DateTime tanggal = tanggalTimestamp.toDate(); // konversi ke format date
      setState(() {
        selectedDate = tanggal; // Set nilai selectedDate sesuai dengan tanggal dari Firestore
      });
    }
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _nimController,
                  decoration: InputDecoration(labelText: 'NIM'),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly // Hanya menerima input angka
                  ], 
                  keyboardType: TextInputType.number, // Keyboard tipe angka
                ),
                TextField(
                  controller: _angkatanController,
                  decoration: InputDecoration(labelText: 'Angkatan'),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly // Hanya menerima input angka
                  ], 
                  keyboardType: TextInputType.number, // Keyboard tipe angka
                ),
                TextField(
                  controller: _tanggalController,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Lahir',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  keyboardType: TextInputType.datetime,
                  readOnly: true, // Input hanya bisa melalui date picker
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text('Update'),
                  onPressed: () async {
                    final String name = _nameController.text;
                    final String nim = _nimController.text;
                    final String angkatan = _angkatanController.text;
                    final String tanggal = _tanggalController.text;
                    try {
                      selectedDate = DateTime.parse(tanggal);
                    } catch (e) {
                      print('Error parsing date: $e'); //menangani kesalahan jika parsing gagal
                    }
                    if (name != "") {
                      await _students.doc(documentSnapshot!.id).update({
                        "name": name,
                        "nim": nim,
                        "angkatan": angkatan,
                        "tanggal": tanggal
                      });
                      _nameController.text = '';
                      _nimController.text = '';
                      _angkatanController.text = '';
                      _tanggalController.text = '';
                    }

                    
                  },
                )
              ],
            ),
          );
        }
    );
  }

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _nameController.text = documentSnapshot['name'];
      _nimController.text = documentSnapshot['nim'];
      _angkatanController.text = documentSnapshot['angkatan'];

      // Format tanggal dari Firestore (string) ke DateTime
      DateTime tanggal = DateTime.parse(documentSnapshot['tanggal']);
      // Set nilai selectedDate sesuai dengan tanggal dari Firestore
      setState(() {
        selectedDate = tanggal;
      });
    }
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _nimController,
                  decoration: InputDecoration(labelText: 'NIM'),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly // Hanya menerima input angka
                  ], 
                  keyboardType: TextInputType.number, // Keyboard tipe angka
                ),
                TextField(
                  controller: _angkatanController,
                  decoration: InputDecoration(labelText: 'Angkatan'),// Hanya menerima input angka
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ], 
                  keyboardType: TextInputType.number, // Keyboard tipe angka
                ),
                TextField(
                  controller: _tanggalController,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Lahir',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  keyboardType: TextInputType.datetime,
                  readOnly: true, // Input hanya bisa melalui date picker
                ),
                IconButton(onPressed: () => _pickAndSetImage(_setImageUrl), icon: Icon(Icons.camera_alt), color: Colors.deepPurple,),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text('Add'),
                  onPressed: () async {
                    final String name = _nameController.text;
                    final String nim = _nimController.text;
                    final String angkatan = _angkatanController.text;
                    final Timestamp tanggalTimestamp = Timestamp.fromDate(selectedDate);

                    // Get current latitude and longitude
                    _currentLocation = await _getCurrentLocation();
                    final String latitude = _currentLocation!.latitude.toString();
                    final String longitude = _currentLocation!.longitude.toString();

                    if (imageUrl.isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('Please Upload an Image')));
                      return;
                    }
                    if (name != "") {
                      await _students.add({
                        "name": name,
                        "nim": nim,
                        "angkatan": angkatan,
                        "tanggal": tanggalTimestamp, // Gunakan tanggal yang diambil dari _tanggalController
                        "timestamps": FieldValue.serverTimestamp(),
                        "image": imageUrl,
                        "latitude": latitude,
                        "longitude": longitude,
                      });
                      _nameController.text = '';
                      _nimController.text = '';
                      _angkatanController.text = '';
                      _tanggalController.text = '';
                      imageUrl = '';
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Data berhasil ditambahkan')));
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          );
        }
    );
  }

  Future<void> _delete(String productId) async {
    await _students.doc(productId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have successfully deleted a student')));
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

  // Fungsi Pembantu Date
  Future<void> _selectDate(BuildContext context) async {
    // Initial DateTime Final Picked
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        // Format tanggal yang dipilih ke dalam string sesuai dengan format yang diinginkan
        _tanggalController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  String _getFormattedTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      // Handle the case when 'timestamps' is null, set a default value or return an empty string
      return 'No Timestamp';
    }
    // Convert the Timestamp to DateTime
    DateTime dateTime = timestamp.toDate();
    // Format the DateTime as a human-readable string (change the format as desired)
    String formattedDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    return formattedDateTime;
  }


  // Fungsi Pembantu Image untuk mengatur imageUrl dengan menggunakan setState.
  void _setImageUrl(String imageUrl) {
    setState(() {
      this.imageUrl = imageUrl;
    });
  }
}
