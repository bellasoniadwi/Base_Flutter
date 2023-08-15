import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:project_sinarindo/materials/addStudent.dart';
import 'package:project_sinarindo/materials/detailScan.dart';
import 'package:project_sinarindo/materials/profile.dart';
import 'package:project_sinarindo/materials/riwayatAbsen.dart';

class Category {
  String thumbnail;
  String name;
  void Function(BuildContext) onTapHandler;

  Category({
    required this.name,
    required this.thumbnail,
    required this.onTapHandler,
  });
}

List<Category> categoryList = [
  Category(
    name: 'Form Absensi',
    thumbnail: 'assets/icons/form.png',
    onTapHandler: (context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddStudent(),
        ),
      );
    },
  ),
  Category(
    name: 'Riwayat Absensi',
    thumbnail: 'assets/icons/history.png',
    onTapHandler: (context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RiwayatAbsen(),
        ),
      );
    },
  ),
  Category(
    name: 'Scanner QR Code',
    thumbnail: 'assets/icons/qrcode.png',
    onTapHandler: (context) {
      scanQR(context); // Panggil fungsi scanQR dengan melewatkan context
  },
  ),
  Category(
    name: 'Lihat Profil',
    thumbnail: 'assets/icons/profile.png',
    onTapHandler: (context) async {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        try {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          
          // Jika data ditemukan, buka halaman profil dengan dokumen snapshot
          if (userDoc.exists) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Profile(documentSnapshot: userDoc),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User data not found')),
            );
          }
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching user data: $error')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
      }
    },
  ),
];

Future<void> scanQR(BuildContext context) async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
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
        
    }
  }
