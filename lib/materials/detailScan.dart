import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_sinarindo/screens/base_screen.dart';

class DetailScan extends StatefulWidget {
  final String? scannedId;

  const DetailScan({Key? key, this.scannedId}) : super(key: key);

  @override
  State<DetailScan> createState() => _DetailScanState();
}

class _DetailScanState extends State<DetailScan> {
  CollectionReference _students = FirebaseFirestore.instance.collection('students');
  Stream<DocumentSnapshot>? _studentStream; // Changed to a Stream

  @override
  void initState() {
    super.initState();
    _studentStream = _students.doc(widget.scannedId!).snapshots(); // Get a stream of the document
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot?>(
        stream: _studentStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching data: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Error'),
                  content: Text('Barcode tidak sesuai', textAlign: TextAlign.center),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
            return BaseScreen();
          }

          DocumentSnapshot documentSnapshot = snapshot.data!;
          if (!documentSnapshot.exists) {
          Future.delayed(Duration.zero, () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Error'),
                  content: Text(
                    'Data dengan ID ${widget.scannedId} tidak ditemukan!',
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          });
          return BaseScreen();
        }

          // Get the data from the documentSnapshot
          String name = documentSnapshot['name'] ?? '';
          String latitude = documentSnapshot['latitude'] ?? '';
          String longitude = documentSnapshot['longitude'] ?? '';
          Timestamp timestamps = documentSnapshot['timestamps'];
          String image = documentSnapshot['image'] ?? '';

          return Column(
            children: [
              Container(
                height: 230,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(50),
                  ),
                  color: Colors.blueAccent,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 80,
                      left: 0,
                      child: Container(
                        height: 100,
                        width: 300,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(50),
                              bottomRight: Radius.circular(50),
                            )),
                      ),
                    ),
                    Positioned(
                        top: 115,
                        left: 20,
                        child: Text(
                          "Detail Absensi",
                          style: TextStyle(fontSize: 30, color: Colors.blueAccent),
                        ))
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Container(
                clipBehavior: Clip.none,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            offset: Offset(-5.0, 10.0),
                            blurRadius: 20.0,
                            spreadRadius: 4.0,
                          )
                        ],
                      ),
                      padding: EdgeInsets.only(
                        left: 145,
                        right: 12,
                        bottom: 30,
                        top: 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Nama          : ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                Expanded(
                                  child: Text(
                                      name ?? '',
                                      style: TextStyle(fontSize: 16)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Latitude      : ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                Expanded(
                                  child: Text(
                                      latitude ?? '',
                                      style: TextStyle(fontSize: 16)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Longitude  : ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                Expanded(
                                  child: Text(
                                      longitude ?? '',
                                      style: TextStyle(fontSize: 16)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tanggal     : ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                Expanded(
                                  child: Text(
                                      _getFormattedDate(timestamps) ??
                                          '',
                                      style: TextStyle(fontSize: 16)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Waktu         : ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                Expanded(
                                  child: Text(
                                      _getFormattedTime(timestamps) ??
                                          '',
                                      style: TextStyle(fontSize: 16)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 5,
                      left: 30,
                      child: Card(
                        elevation: 10.0,
                        shadowColor: Colors.grey.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Container(
                          height: 150,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image: NetworkImage(
                                    image ?? '')),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FloatingActionButton(
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
            ],
          );
        },
      ),
    );
  }

  String _getFormattedDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'No Timestamp';
    }
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return formattedDate;
  }

  String _getFormattedTime(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'No Timestamp';
    }
    DateTime dateTime = timestamp.toDate();
    String formattedTime = DateFormat('HH:mm:ss').format(dateTime);
    return formattedTime;
  }
}
