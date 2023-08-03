import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserData extends ChangeNotifier {
  String? name;
  String? email;

  // Metode untuk memuat data pengguna dari Firestore berdasarkan UID
  Future<void> fetchUserData(String uid) async {
    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        name = userDoc.data()?['name'];
        email = userDoc.data()?['email'];
        notifyListeners();
      }
    } catch (error) {
      print("Error fetching user data: $error");
    }
  }
  
  // Metode untuk memperbarui data pengguna
  void updateUserData(String newName, String newEmail) {
    name = newName;
    email = newEmail;
    notifyListeners();
  }
}
