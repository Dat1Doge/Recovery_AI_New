import 'package:flutter/material.dart';

class TrainPage extends StatefulWidget {
  const TrainPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<TrainPage> createState() => _TrainPageState();
}

class _TrainPageState extends State<TrainPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
              ),
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
