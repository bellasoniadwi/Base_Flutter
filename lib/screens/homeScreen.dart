import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:project_sinarindo/auth/signin_screen.dart';
import 'package:project_sinarindo/material/customappbar.dart';
import 'package:project_sinarindo/screens/addStudent.dart';
import 'package:project_sinarindo/screens/detailScan.dart';
import 'package:project_sinarindo/screens/detailStudent.dart';
import 'package:project_sinarindo/screens/editStudent.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mendefinisikan variabel
  final CollectionReference _students =
      FirebaseFirestore.instance.collection('students');
  DateTime selectedDate = DateTime.now();
  String imageUrl = '';
  String? _userName;

  void initState() {
    super.initState();
    fetchUserDataFromFirestore();
  }

  Future<void> fetchUserDataFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Ambil data pengguna dari Firestore berdasarkan UID
        var userDoc =
            await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _userName = userDoc.data()?['name'] ?? 'Guest';
          });
        }
      }
    } catch (error) {
      print("Error fetching user data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: CustomAppBar(),
        ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        overlayOpacity: 0.1,
        overlayColor: Colors.black,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddStudent()),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.qr_code_scanner),
            onTap: () => scanQR(),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: StreamBuilder(
        stream: _students
            .where('name', isEqualTo: _userName) // Filter documents by 'name'
            .snapshots(),
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
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => DetailStudent(
                        documentSnapshot: documentSnapshot),
                      ),
                    ),
                    leading: ClipOval(
                      child: Image.network(
                        documentSnapshot['image'],
                        width:
                            50, // Sesuaikan ukuran gambar sesuai kebutuhan Anda
                        height:
                            50, // Sesuaikan ukuran gambar sesuai kebutuhan Anda
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(documentSnapshot['name']),
                    subtitle: Text(
                        _getFormattedTimestamp(documentSnapshot['timestamps'])),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditStudent(
                                  documentSnapshot: documentSnapshot),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteStudent(documentSnapshot.id),
                        ),
                      ],
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

  Future<void> _deleteStudent(String productId) async {
    await _students.doc(productId).delete();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a student')));
  }

  Future<void> scanQR() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.QR,
      );

      // Redirect to the detail page with the scanned document ID
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScan(
            scannedNIM: barcodeScanRes,
          ),
        ),
      );
    } on PlatformException {
      setState(() {
        // Handle the error
      });
    }
  }
}