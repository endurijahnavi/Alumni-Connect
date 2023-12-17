import 'package:appdevproject/Authentication/auth_services.dart';
import 'package:appdevproject/Screens/FeedScreen.dart';
import 'package:appdevproject/Widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController _userNameTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(82, 184, 206, 100),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(82, 184, 206, 100),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 200),
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(
                      'Sign up',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 20),
                reusableTextField(
                  "Enter Username",
                  Icons.person_outline,
                  false,
                  _userNameTextController,
                ),
                const SizedBox(height: 20),
                reusableTextField(
                  "Enter Email",
                  Icons.email_outlined,
                  false,
                  _emailTextController,
                ),
                const SizedBox(height: 20),
                reusableTextField(
                  "Enter Password",
                  Icons.lock_outlined,
                  true,
                  _passwordTextController,
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : button(context, "Sign Up", _signUp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    // Validate input
    if (_userNameTextController.text.isEmpty ||
        _emailTextController.text.isEmpty ||
        !RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$")
            .hasMatch(_emailTextController.text) ||
        _passwordTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter valid details"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    bool isValid = await AuthService.signUp(_userNameTextController.text,
        _emailTextController.text, _passwordTextController.text);
    if (isValid) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => FeedScreen(
                  currentUserId: FirebaseAuth.instance.currentUser!.uid,
                )),
      );
    } else {
      print('something wrong');
    }
    // FirebaseAuth.instance
    //     .createUserWithEmailAndPassword(
    //   email: _emailTextController.text,
    //   password: _passwordTextController.text,
    // )
    //     .then((value) {
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   print("Created New Account");
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => HomeScreen()),
    // );
    // }).catchError((error) {
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   print("Error: ${error.toString()}");
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text("Error: ${error.toString()}"),
    //       duration: Duration(seconds: 2),
    //     ),
    //   );
    // });
  }
}
