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
    thumbnail: 'assets/icons/laptop.jpg',
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
    thumbnail: 'assets/icons/accounting.jpg',
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
    thumbnail: 'assets/icons/photography.jpg',
    onTapHandler: (context) {
      scanQR(context); // Panggil fungsi scanQR dengan melewatkan context
  },
  ),
  Category(
    name: 'Lihat Profil',
    thumbnail: 'assets/icons/design.jpg',
    onTapHandler: (context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Profile(),
        ),
      );
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
