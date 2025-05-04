import 'package:flutter/material.dart';
import 'Diagnose.dart';
import 'Rehab.dart';
import 'Train.dart';
import 'Log_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toastification/toastification.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  User? user = FirebaseAuth.instance.currentUser;
  String? userName;
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    if (user != null) {
      print("entered");
      final docRef = db.collection("users").doc(user?.uid);
      docRef.get().then(
        (DocumentSnapshot doc) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            userName = data["name"];
          });
          print(userName);
        },
        onError: (e) => print("Error getting document: $e"),
      );
    }
  }

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
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Row(
        children: [
          Expanded(
            child: Container(
              // Center is a layout widget. It takes a single child and positions it
              // in the middle of the parent.
              padding: EdgeInsets.all(10),
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                      "Welcome, ${userName ?? 'Loading...'}",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          onTap: (){
                            //print("Diagnosis");
                            Navigator.push(context, MaterialPageRoute(builder: (context) => DiagnosePage(title: "Diagnosis")));
                          },
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0,5,30,0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Image.network(
                                      scale: 10,
                                      "https://cdn2.iconfinder.com/data/icons/minimal-set-three/32/minimal-55-512.png",
                                    ),
                                    Text(
                                      "Diagnosis",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "Self report symptoms, enter X-Rays and sync watch data to get an unofficial injury diagnosis",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            //print("Rehab");
                            Navigator.push(context, MaterialPageRoute(builder: (context) => RehabPage(title: "Rehab")));
                          },
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0,30,30,0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Image.network(
                                      scale: 9,
                                      "https://cdn-icons-png.flaticon.com/512/414/414352.png",
                                    ),
                                    Text(
                                      "Rehab",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "Short summary here of targeted injury/injuries and rehab regiment",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            //print("Training");
                            Navigator.push(context, MaterialPageRoute(builder: (context) => TrainPage(title: "Training")));
                          },
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0,30,30,0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Image.network(
                                      scale: 5.5,
                                      "https://assets.streamlinehq.com/image/private/w_300,h_300,ar_1/f_auto/v1/icons/sports/dumbbell-small-1qfko1lmyvwtsldrbqetds.png/dumbbell-small-ab9jlu7m0yrs68flladihl.png?_a=DAJFJtWIZAAC",
                                    ),
                                    Text(
                                      "Training",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "Short summary here of mileage goal, workouts, up or down week, etc.",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            showToast("Logged out successfully",isError: false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LogInPage(title: "Log in"))
                            );
                          },
                          child: Text(
                            "Log out",
                            style: TextStyle(fontSize: 30),
                          ),
                        ),
                      ],
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
