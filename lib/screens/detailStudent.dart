import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_sinarindo/main.dart';

class DetailStudent extends StatefulWidget {
  final DocumentSnapshot? documentSnapshot;

  const DetailStudent({Key? key, this.documentSnapshot}) : super(key: key);

  @override
  State<DetailStudent> createState() => _DetailStudentState();
}

class _DetailStudentState extends State<DetailStudent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 230,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(50),
              ),
              color: Colors.deepPurple,
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
                      "Detail Biodata",
                      style: TextStyle(fontSize: 30, color: Colors.deepPurple),
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
                            const Text('NIM             : ',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                            Expanded(
                              child: Text(widget.documentSnapshot?['nim'] ?? '',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
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
                              child: Text(widget.documentSnapshot?['name'] ?? '',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Angkatan    : ',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            Expanded(
                              child: Text(
                                widget.documentSnapshot?['angkatan'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
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
                              child: Text(widget.documentSnapshot?['latitude'] ?? '',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Longitude   : ',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                            Expanded(
                              child: Text(widget.documentSnapshot?['longitude'] ?? '',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Timestamp : ',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                            Expanded(
                              child: Text(_getFormattedTimestamp(widget.documentSnapshot?['timestamps']) ?? '',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -30,
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
                            widget.documentSnapshot?['image'] ?? ''
                          )
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomePage()))
              .then((data) {});
        },
        child: const Icon(Icons.arrow_back, color: Colors.white,),
        backgroundColor: Colors.deepPurple,
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
