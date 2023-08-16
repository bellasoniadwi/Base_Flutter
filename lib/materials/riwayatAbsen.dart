import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:project_sinarindo/constants/color.dart';
import 'package:project_sinarindo/materials/detailStudent.dart';
import 'package:project_sinarindo/screens/base_screen.dart';
import 'package:project_sinarindo/screens/details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RiwayatAbsen extends StatefulWidget {
  const RiwayatAbsen({Key? key}) : super(key: key);

  @override
  _RiwayatAbsenState createState() => _RiwayatAbsenState();
}

class _RiwayatAbsenState extends State<RiwayatAbsen> {
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
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: StreamBuilder(
            stream: _students
                .where('name',
                    isEqualTo: _userName) // Filter documents by 'name'
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              if (streamSnapshot.hasData) {
                return SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IntrinsicHeight(
                          child: Stack(
                            children: [
                              Align(
                                child: Text(
                                  'Riwayat Absensi',
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
                                ),
                              ),
                              // Positioned(
                              //   left: 0,
                              //   child: CustomIconButton(
                              //     child: const Icon(Icons.arrow_back),
                              //     height: 35,
                              //     width: 35,
                              //     onTap: () => Navigator.pop(context),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: streamSnapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              // final Riwayat riwayat = riwayats[index];
                              final DocumentSnapshot documentSnapshot =
                                  streamSnapshot.data!.docs[index];
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailStudent(documentSnapshot: documentSnapshot),
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(documentSnapshot['name']),
                                            Text(
                                              _getFormattedTimestamp(
                                                  documentSnapshot[
                                                      'timestamps']),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                            Text(
                                                  documentSnapshot[
                                                      'keterangan'],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                          ],
                                        ),
                                      ),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                        documentSnapshot['image'],
                                        width:
                                            60, // Sesuaikan ukuran gambar sesuai kebutuhan Anda
                                        height:
                                            80, // Sesuaikan ukuran gambar sesuai kebutuhan Anda
                                        fit: BoxFit.cover,
                                      ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(context,
                        MaterialPageRoute(builder: (context) => BaseScreen()))
                    .then((data) {});
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              backgroundColor: Colors.blueAccent,
            ),
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
}
