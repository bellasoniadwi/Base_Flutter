import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_sinarindo/screens/base_screen.dart';
import 'package:provider/provider.dart';
import 'package:project_sinarindo/models/user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _Profile();
}

class _Profile extends State<Profile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pelatihController = TextEditingController();
  final TextEditingController _nomorindukController = TextEditingController();
  final TextEditingController _angkatanController = TextEditingController();
  String image = '';

  void initState() {
    super.initState();
    fetchUserDataFromFirestore();
  }

  Future<void> fetchUserDataFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          String name = userDoc.data()?['name'] ?? '';
          String email = userDoc.data()?['email'] ?? '';
          String pelatih = userDoc.data()?['didaftarkan_oleh'] ?? '';
          String image = userDoc.data()?['image'] ?? '';
          String nomor_induk = userDoc.data()?['nomor_induk'] ?? '';
          String angkatan = userDoc.data()?['angkatan'] ?? '';
          _nameController.text = name;
          _pelatihController.text = pelatih;
          _nomorindukController.text = nomor_induk;
          _angkatanController.text = angkatan;
          Provider.of<UserData>(context, listen: false).updateUserData(
              name, email, pelatih, image, nomor_induk, angkatan);
        }
      }
    } catch (error) {
      print("Error fetching user data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);

    // Dapatkan data Nama dan Email dari variabel global
    final String accountName = userData.name ?? 'Name';
    final String accountImage = userData.image ??
        'https://img.freepik.com/free-icon/user_318-159711.jpg';
    final String accountPelatih = userData.pelatih ?? 'Pelatih';
    final String accountNomorInduk = userData.nomor_induk ?? 'Nomor Induk';
    final String accountAngkatan = userData.angkatan ?? 'Angkatan';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 210,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(50),
                ),
                color: Colors.deepPurple,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 65,
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
                      top: 95,
                      left: 20,
                      child: Text(
                        "Profil Saya",
                        style: TextStyle(fontSize: 30, color: Colors.deepPurple),
                      ))
                ],
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff7c94b6),
                      image: DecorationImage(
                        image: NetworkImage(accountImage),
                        fit: BoxFit.fitWidth,
                      ),
                      border: Border.all(
                        color: Colors.deepPurple,
                        width: 8,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 3,
                          // offset: Offset(2, 2), // Shadow position
                        ),
                      ],
                    ),
                    height: 200,
                    width: 200,
                    margin: const EdgeInsets.only(left: 50.0, right: 30.0, top: 30),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Masukkan Nama',
                      labelText: 'NAMA',
                    ),
                    enabled: false,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  TextField(
                    controller: _pelatihController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Masukkan Pelatih',
                      labelText: 'PELATIH',
                    ),
                    enabled: false,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  TextField(
                    controller: _nomorindukController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Masukkan Nomor Induk',
                      labelText: 'NOMOR INDUK',
                    ),
                    enabled: false,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  TextField(
                    controller: _angkatanController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Masukkan Angkatan',
                      labelText: 'ANGKATAN',
                    ),
                    enabled: false,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
