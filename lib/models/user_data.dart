import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserData extends ChangeNotifier {
  String? name;
  String? email;
  String? pelatih;
  String? image;
  String? nomor_induk;
  String? angkatan;

  // Metode untuk memuat data pengguna dari Firestore berdasarkan UID
  Future<void> fetchUserData(String uid) async {
    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        name = userDoc.data()?['name'];
        email = userDoc.data()?['email'];
        pelatih = userDoc.data()?['didaftarkan_oleh'];
        image = userDoc.data()?['image'];
        nomor_induk = userDoc.data()?['nomor_induk'];
        angkatan = userDoc.data()?['angkatan'];
        notifyListeners();
      }
    } catch (error) {
      print("Error fetching user data: $error");
    }
  }
  
  // Metode untuk memperbarui data pengguna
  void updateUserData(String newName, String newEmail, String newPelatih, String newImage, String newNomorinduk, String newAngkatan) {
    name = newName;
    email = newEmail;
    pelatih = newPelatih;
    image = newImage;
    nomor_induk = newNomorinduk;
    angkatan = newAngkatan;
    notifyListeners();
  }
}
