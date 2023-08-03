import 'package:project_sinarindo/screens/homeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_sinarindo/models/user_data.dart';
import 'package:project_sinarindo/reusable_widgets/reusable_widget.dart';
import 'package:project_sinarindo/utils/color_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            hexStringToColor("D3D3D3"),
            hexStringToColor("696969"),
            hexStringToColor("000000")
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: <Widget>[
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
                SignInSignUpButton(context, true, () {
                  FirebaseAuth.instance
                  .signInWithEmailAndPassword(
                    email: _emailTextController.text, 
                    password: _passwordTextController.text)
                    .then((value) async {
                      Provider.of<UserData>(context, listen: false).updateUserData(
                        value.user?.displayName ?? "Guest", value.user?.email ?? "guest@example.com");

                        // Set status login sebagai true saat pengguna berhasil login
                        final SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setBool('isLoggedIn', true);
              
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                    }).onError((error, stackTrace) {
                      print("Error ${error.toString()}");
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${error.toString()}')));
                    });
                }),
                // signUpOption()
              ]
            ),
          )
        ),
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
