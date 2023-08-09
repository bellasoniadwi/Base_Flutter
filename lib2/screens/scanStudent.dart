import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'detailScan.dart';

class ScanStudent extends StatefulWidget {
  const ScanStudent({Key? key}) : super(key: key);

  @override
  State<ScanStudent> createState() => _ScanStudentState();
}

class _ScanStudentState extends State<ScanStudent> {
  final CollectionReference _students =
      FirebaseFirestore.instance.collection('students');

  @override
  void initState() {
    super.initState();
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
            scannedId: barcodeScanRes,
          ),
        ),
      );
    } on PlatformException {
      setState(() {
        // Handle the error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Barcode scan'), backgroundColor: Colors.deepPurple,),
        body: Builder(builder: (BuildContext context) {
          return Container(
            alignment: Alignment.center,
            child: Flex(
              direction: Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.deepPurple
                  ),
                  onPressed: () => scanQR(),
                  child: Text('Start QR scan'),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
