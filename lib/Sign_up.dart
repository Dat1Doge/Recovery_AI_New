import 'package:flutter/material.dart';
import 'package:recovery_ai/Log_in.dart';
import 'Home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_database/firebase_database.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  void showToast(String message, {bool isError = true}) {
    toastification.show(
      context: context, // Remove if using ToastificationWrapper
      title: Text(isError ? "Error" : "Success"),
      description: Text(message),
      type: isError ? ToastificationType.error : ToastificationType.success,
      style: ToastificationStyle.fillColored, // Or any other style
      autoCloseDuration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(16),
      //position: ToastificationPosition.bottom,
    );
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      print("test");
      RegExp exp = RegExp(".+@.+\\..+");
      if (!exp.hasMatch(email)){
        showToast("Invalid Email", isError: true);
        return null;
      }
      if (passwordController.text.length < 6){
        showToast("Password must be at least 6 characters long", isError:  true);
        return null;
      }
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("Signed up success");

      return userCredential.user; // Returns user if successful
    } catch (e) {
      print("Sign-Up Error: $e");
      return null;
    }
  }

  //FirebaseDatabase database = FirebaseDatabase.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the SignUpPage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(30),
              color: Colors.blue,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 0),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 48,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0,10,0,3),
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 4, color: Colors.black26),
                          ),
                          labelText: 'Email'
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0,3,0,3),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 4, color: Colors.black26),
                        ),
                        labelText: 'Password'
                      ),
                      onChanged: (text) {

                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0,3,0,20),
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 4, color: Colors.black26),
                          ),
                          labelText: 'First name/Nickname'
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      User? user = await signUpWithEmail(emailController.text, passwordController.text);
                      if (user != null)
                      {
                        FirebaseFirestore firestore = FirebaseFirestore.instance;
                        await firestore.collection('users').doc(user.uid).set({
                          'name': nameController.text,
                          'email': user.email
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LogInPage(title: "Log in"))
                        );
                      }
                    },
                    child: Text(
                      "Confirm",
                      style: TextStyle(fontSize: 30),
                    )
                  ),
                ],
              ),
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
