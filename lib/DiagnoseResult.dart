import 'package:flutter/material.dart';

class DiagnoseResultPage extends StatefulWidget {
  const DiagnoseResultPage({super.key, required this.title});

  final String title;

  @override
  State<DiagnoseResultPage> createState() => _DiagnoseResultPageState();
}

class _DiagnoseResultPageState extends State<DiagnoseResultPage> {
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(

      ),
    );
  }
}
