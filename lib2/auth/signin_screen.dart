import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_sinarindo/constants/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_sinarindo/models/user_data.dart';
import 'package:project_sinarindo/reusable_widgets/reusable_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/homeScreen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
            hexStringToColor("CF40FF"),
            hexStringToColor("9546C4"),
            hexStringToColor("5E61F4")
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.fromLTRB(
              20, MediaQuery.of(context).size.height * 0.2, 20, 0),
          child: Column(children: <Widget>[
            logoWidget("assets/images/logo1.png"),
            SizedBox(
              height: 30,
            ),
            reusableTextField(
              "Enter Email",
              Icons.mail,
              controller: _emailTextController,
            ),
            SizedBox(
              height: 30,
            ),
            reusableTextField(
              "Enter Password",
              Icons.lock_outlined,
              isPasswordType: true,
              isPasswordVisible: _isPasswordVisible,
              controller: _passwordTextController,
              onTogglePasswordVisibility: (isVisible) {
                setState(() {
                  _isPasswordVisible = isVisible;
                });
              },
            ),
            SizedBox(
              height: 30,
            ),
            AuthButton(context, true, () async {
              try {
                final UserCredential userCredential =
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: _emailTextController.text,
                        password: _passwordTextController.text);

                final String uid = userCredential.user?.uid ?? '';

                var userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .get();
                if (userDoc.exists) {
                  String role = userDoc.data()?['role'] ?? '';
                  if (role == 'Siswa') {
                    String pelatih = userDoc.data()?['didaftarkan_oleh'] ?? '';
                    String image = userDoc.data()?['image'] ?? '';
                    String nomor_induk = userDoc.data()?['nomor_induk'] ?? '';
                    String angkatan = userDoc.data()?['angkatan'] ?? '';

                    Provider.of<UserData>(context, listen: false)
                        .updateUserData(
                            userCredential.user?.displayName ?? "Guest",
                            userCredential.user?.email ?? "guest@example.com",
                            pelatih, image, nomor_induk, angkatan);

                    // Set status login sebagai true saat pengguna berhasil login
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool('isLoggedIn', true);

                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'You are not allowed to log in. Please contact the admin.')));
                  }
                }
              } catch (error) {
                print("Error ${error.toString()}");
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(
                            'Invalid Email or Password')));
              }
            }),
            // signUpOption()
          ]),
        )),
      ),
    );
  }

  // Row signUpOption() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       const Text("Don't have account?",
  //           style: TextStyle(color: Colors.white70)),
  //       GestureDetector(
  //         onTap: () {
  //           Navigator.push(context,
  //               MaterialPageRoute(builder: (context) => SignUpScreen()));
  //         },
  //         child: const Text(
  //           "  Sign Up",
  //           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  //         ),
  //       )
  //     ],
  //   );
  // }
}
