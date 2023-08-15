import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_sinarindo/auth/signin_screen.dart';
import 'package:project_sinarindo/models/user_data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatefulWidget {
  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
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
          String name = userDoc.data()?['name'] ?? 'Guest';
          String email = userDoc.data()?['email'] ?? 'guest@example.com';
          String pelatih = userDoc.data()?['didaftarkan_oleh'] ?? 'guest@example.com';
          String image = userDoc.data()?['image'] ?? 'https://img.freepik.com/free-icon/user_318-159711.jpg';
          String nomor_induk = userDoc.data()?['nomor_induk'] ?? 'https://img.freepik.com/free-icon/user_318-159711.jpg';
          String angkatan = userDoc.data()?['angkatan'] ?? 'https://img.freepik.com/free-icon/user_318-159711.jpg';
          Provider.of<UserData>(context, listen: false)
              .updateUserData(name, email, pelatih, image, nomor_induk, angkatan);
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
    final String accountName = userData.name ?? 'Guest';
    final String urlImage = userData.image ?? 'https://img.freepik.com/free-icon/user_318-159711.jpg';
    
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
      height: 130,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.1, 0.5],
          colors: [
            Color.fromARGB(255, 18, 95, 238),
            Color.fromARGB(255, 69, 122, 220),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage('$urlImage'),
              ),
              // Expanded(
              //   flex: 2, // Menggunakan lebih banyak ruang daripada elemen lain dalam Row
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Padding(
              //         padding: const EdgeInsets.only(left: 5),
              //         child: Text(
              //           "Hello,\n$accountName",
              //           style: Theme.of(context).textTheme.titleLarge,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.logout,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.remove('isLoggedIn'); // Hapus status login saat logout
                    print("Signed Out");
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignInScreen()));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}