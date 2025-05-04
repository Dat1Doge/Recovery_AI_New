import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'Home.dart';
import 'Sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey[900]!),
      ),
      home: const LogInPage(title: 'Recovery AI'),
    );
  }
}

class LogInPage extends StatefulWidget {
  const LogInPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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

  Future<User?> logInWithEmail(String email, String password) async {
    //await FirebaseAppCheck.instance.getToken(true); // force refresh
    try {
      RegExp exp = RegExp(".+@.+\\..+");
      if (!exp.hasMatch(email)){
        showToast("Invalid Email", isError: true);
        return null;
      }
      if (passwordController.text.length < 6){
        showToast("Password must be at least 6 characters long", isError:  true);
        return null;
      }
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password,
      );
      print("Log in success");

      return userCredential.user; // Returns user if successful
    } catch (e) {
      print(e);
      if(e.toString() == "[firebase_auth/invalid-credential] The supplied auth credential is incorrect, malformed or has expired."){
        showToast("Invalid Credentials", isError: true);
      }
      else{
        showToast("Unknown Error", isError: true);
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the LogInPage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Container(
          padding: EdgeInsets.all(30),
          color: Colors.blue,
          //width: ,
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            //
            // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
            // action in the IDE, or press "p" in the console), to see the
            // wireframe for each widget.
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(vertical: 0),
                child: const Text(
                  'Recovery AI',
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
                margin: EdgeInsets.fromLTRB(0,3,0,10),
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
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0,0,0,30),
                child: ElevatedButton(
                  onPressed: () async{
                    var r = await logInWithEmail(emailController.text, passwordController.text);
                    if (r != null){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage(title: "Home"))
                      );
                    }
                  },
                  child: Text(
                    "Log in",
                    style: TextStyle(fontSize: 30),
                  )
                ),
              ),
              Text(
                "Don't have an account?",
                style: TextStyle(fontSize: 32),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0,5,0,5),
                child: ElevatedButton(
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage(title: "Sign up"))
                    );
                  },
                  child: Text(
                    "Sign up",
                    style: TextStyle(fontSize: 30),
                  )
                ),
              ),
            ],
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
