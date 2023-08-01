import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class ScanStudent extends StatefulWidget {
  final DocumentSnapshot? documentSnapshot;

  const ScanStudent({Key? key, this.documentSnapshot}) : super(key: key);

  @override
  State<ScanStudent> createState() => _ScanStudentState();
}

class _ScanStudentState extends State<ScanStudent> {
  final CollectionReference _students =
      FirebaseFirestore.instance.collection('students');

  String _scanBarcode = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  Future<void> scanQR() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);

      // Get data from Firestore based on scanned document ID
      DocumentSnapshot documentSnapshot =
          await _students.doc(barcodeScanRes).get();

      if (documentSnapshot.exists) {
        setState(() {
          _scanBarcode = documentSnapshot.data().toString();
        });
      } else {
        setState(() {
          _scanBarcode = 'Document not found in Firestore';
        });
      }
    } on PlatformException {
      setState(() {
        _scanBarcode = 'Failed to get platform version.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: const Text('Barcode scan')),
            body: Builder(builder: (BuildContext context) {
              return Container(
                  alignment: Alignment.center,
                  child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                            onPressed: () => scanQR(),
                            child: Text('Start QR scan')),
                        Text('Scan result : $_scanBarcode\n',
                            style: TextStyle(fontSize: 20))
                      ]));
            })));
  }
}
