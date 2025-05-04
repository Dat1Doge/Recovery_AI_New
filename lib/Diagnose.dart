import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'Home.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';

import 'package:firebase_app_check/firebase_app_check.dart';

class DiagnosePage extends StatefulWidget {
  const DiagnosePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<DiagnosePage> createState() => _DiagnosePageState();
}

class _DiagnosePageState extends State<DiagnosePage> {
  String _imagePath = "";
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore db = FirebaseFirestore.instance;

  //GPT stuff
  String OpenAIKey = String.fromEnvironment("OPENAI_KEY");
  int temperature = 1;

  //slider pain values
  double lHamstringPain = 0;
  double rHamstringPain = 0;
  double lQuadPain = 0;
  double rQuadPain = 0;
  double lKneePain = 0;
  double rKneePain = 0;
  double lCalfPain = 0;
  double rCalfPain = 0;
  double lAnklePain = 0;
  double rAnklePain = 0;

  //additional info text
  final additionalInfoController = TextEditingController();

  //image stuff
  List<PlatformFile> selectedFiles = [];
  List<String> fileURLS = [];
  int carouselIndex = 0;

  String get stringifyFileURLS {
    String out = "";
    int index = 1;
    for (String url in fileURLS){
      out += "\nimage${index}: ${url}";
      index++;
    }
    return out;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<String> get _devMsg async {
    final path = await _localPath;
    final file = File('$path/GPTprompt/DeveloperMessage.txt');
    return await file.readAsString();
  }

  Future<String> get _userMsg async { //may remove?
    final path = await _localPath;
    final file = File('$path/GPTprompt/UserMessage.txt');
    return await file.readAsString();
  }

  Future<void> updateURLS() async {
    fileURLS.clear();
    final userFiles = await FirebaseStorage.instance.ref().child("uploads/${user?.uid}").listAll();
    for (var item in userFiles.items) {
      final url = await item.getDownloadURL();
      fileURLS.add(url);
    }
  }

  Future<void> ai_analyze() async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $OpenAIKey',
    };
    final data = {//test
      'model': 'gpt-4.1-mini',
      'messages': [
        {
          'role': 'developer',
          'content': _devMsg,
        },
        {
          'role': 'user',
          'content': {
            '''
            lHamstringPain = ${lHamstringPain}
            rHamstringPain = ${rHamstringPain}
            lQuadPain = ${lQuadPain}
            rQuadPain = ${rQuadPain}
            lKneePain = ${lKneePain}
            rKneePain = ${rKneePain}
            lCalfPain = ${lCalfPain}
            rCalfPain = ${rCalfPain}
            lAnklePain = ${lAnklePain}
            rAnklePain = ${rAnklePain}
            Images: ${stringifyFileURLS}
            Additional Information: 
            ${additionalInfoController.text}
            '''
          },
        }
      ],
      'temperature': temperature,
    };

    try {
      final response = await http.post(url, headers: headers, body: jsonEncode(data));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

      } else {
        print('Failed to generate questions. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    db.collection("Diagnosis").doc(user?.uid).get().then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey("Symptoms")) {
        final symptoms = data["Symptoms"];
        setState(() {
          lHamstringPain = symptoms["lHamstringPain"];
          rHamstringPain = symptoms["rHamstringPain"];
          lQuadPain = symptoms["lQuadPain"];
          rQuadPain = symptoms["rQuadPain"];
          lKneePain = symptoms["lKneePain"];
          rKneePain = symptoms["rKneePain"];
          lCalfPain = symptoms["lCalfPain"];
          rCalfPain = symptoms["rCalfPain"];
          lAnklePain = symptoms["lAnklePain"];
          rAnklePain = symptoms["rAnklePain"];
        });
      }
    }, onError: (e) => print("Error getting document: $e"));
    db.collection("AdditionalInfo").doc(user?.uid).get().then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey("Text")) {
        final text = data["Text"];
        setState(() {
          additionalInfoController.text = text;
        });
      }
    }, onError: (e) => print("Error getting document: $e"));
    loadImages();
  }

  Future<void> loadImages() async {
    await updateURLS();
    if (fileURLS.isNotEmpty) {
      setState(() {
        _imagePath = fileURLS[0];
        carouselIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            tabs: [
              Tab(
                text: "Symptoms",
              ),
              Tab(
                text: "Watch Data",
              ),
              Tab(
                text: "Scans",
              ),
              Tab(
                text: "Confirm",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                Expanded(
                    child: Container(
                      padding: EdgeInsets.all(30),
                      color: Colors.blue,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Rate your pain in these different areas from a scale of 1-10",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          Row(
                              children: [
                                Container(
                                  child: Text("Left Hamstring"),
                                  width: 120,
                                ),
                                Slider(
                                  value: lHamstringPain,
                                  max: 10,
                                  divisions: 10,
                                  onChanged: (double value) {
                                    setState(() {
                                      lHamstringPain = value;
                                    });
                                  },
                                ),
                                Text(
                                  lHamstringPain.toString(),
                                  style: TextStyle(
                                    fontWeight: lHamstringPain > 0 ? FontWeight.bold : FontWeight.w400,
                                  ),
                                ),
                              ]
                          ),
                          Row(
                              children: [
                                Container(
                                  child: Text("Right Hamstring"),
                                  width: 120,
                                ),
                                Slider(
                                  value: rHamstringPain,
                                  max: 10,
                                  divisions: 10,
                                  onChanged: (double value) {
                                    setState(() {
                                      rHamstringPain = value;
                                    });
                                  },
                                ),
                                Text(
                                  rHamstringPain.toString(),
                                  style: TextStyle(
                                    fontWeight: rHamstringPain > 0 ? FontWeight.bold : FontWeight.w400,
                                  ),
                                ),
                              ]
                          ),
                          Row(
                              children: [
                                Container(
                                  child: Text("Left Quad"),
                                  width: 120,
                                ),
                                Slider(
                                  value: lQuadPain,
                                  max: 10,
                                  divisions: 10,
                                  onChanged: (double value) {
                                    setState(() {
                                      lQuadPain = value;
                                    });
                                  },
                                ),
                                Text(
                                  lQuadPain.toString(),
                                  style: TextStyle(
                                    fontWeight: lQuadPain > 0 ? FontWeight.bold : FontWeight.w400,
                                  ),
                                ),
                              ]
                          ),
                          Row(
                              children: [
                                Container(
                                  child: Text("Right Quad"),
                                  width: 120,
                                ),
                                Slider(
                                  value: rQuadPain,
                                  max: 10,
                                  divisions: 10,
                                  onChanged: (double value) {
                                    setState(() {
                                      rQuadPain = value;
                                    });
                                  },
                                ),
                                Text(
                                  rQuadPain.toString(),
                                  style: TextStyle(
                                    fontWeight: rQuadPain > 0 ? FontWeight.bold : FontWeight.w400,
                                  ),
                                ),
                              ]
                          ),
                          Row(
                              children: [
                                Container(
                                  child: Text("Left Knee"),
                                  width: 120,
                                ),
                                Slider(
                                  value: lKneePain,
                                  max: 10,
                                  divisions: 10,
                                  onChanged: (double value) {
                                    setState(() {
                                      lKneePain = value;
                                    });
                                  },
                                ),
                                Text(
                                  lKneePain.toString(),
                                  style: TextStyle(
                                    fontWeight: lKneePain > 0 ? FontWeight.bold : FontWeight.w400,
                                  ),
                                ),
                              ]
                          ),
                          Row(
                              children: [
                                Container(
                                  child: Text("Right Knee"),
                                  width: 120,
                                ),
                                Slider(
                                  value: rKneePain,
                                  max: 10,
                                  divisions: 10,
                                  onChanged: (double value) {
                                    setState(() {
                                      rKneePain = value;
                                    });
                                  },
                                ),
                                Text(
                                  rKneePain.toString(),
                                  style: TextStyle(
                                    fontWeight: rKneePain > 0 ? FontWeight.bold : FontWeight.w400,
                                  ),
                                ),
                              ]
                          ),
                          Row(
                              children: [
                                Container(
                                  child: Text("Left Calf"),
                                  width: 120,
                                ),
                                Slider(
                                  value: lCalfPain,
                                  max: 10,
                                  divisions: 10,
                                  onChanged: (double value) {
                                    setState(() {
                                      lCalfPain = value;
                                    });
                                  },
                                ),
                                Text(
                                  lCalfPain.toString(),
                                  style: TextStyle(
                                    fontWeight: lCalfPain > 0 ? FontWeight.bold : FontWeight.w400,
                                  ),
                                ),
                              ]
                          ),
                          Row(
                              children: [
                                Container(
                                  child: Text("Right Calf"),
                                  width: 120,
                                ),
                                Slider(
                                  value: rCalfPain,
                                  max: 10,
                                  divisions: 10,
                                  onChanged: (double value) {
                                    setState(() {
                                      rCalfPain = value;
                                    });
                                  },
                                ),
                                Text(
                                  rCalfPain.toString(),
                                  style: TextStyle(
                                    fontWeight: rCalfPain > 0 ? FontWeight.bold : FontWeight.w400,
                                  ),
                                ),
                              ]
                          ),
                          Row(
                              children: [
                                Container(
                                  child: Text("Left Ankle"),
                                  width: 120,
                                ),
                                Slider(
                                  value: lAnklePain,
                                  max: 10,
                                  divisions: 10,
                                  onChanged: (double value) {
                                    setState(() {
                                      lAnklePain = value;
                                    });
                                  },
                                ),
                                Text(
                                  lAnklePain.toString(),
                                  style: TextStyle(
                                    fontWeight: lAnklePain > 0 ? FontWeight.bold : FontWeight.w400,
                                  ),
                                ),
                              ]
                          ),
                          Row(
                              children: [
                                Container(
                                  child: Text("Right Ankle"),
                                  width: 120,
                                ),
                                Slider(
                                  value: rAnklePain,
                                  max: 10,
                                  divisions: 10,
                                  onChanged: (double value) {
                                    setState(() {
                                      rAnklePain = value;
                                    });
                                  },
                                ),
                                Text(
                                  rAnklePain.toString(),
                                  style: TextStyle(
                                    fontWeight: rAnklePain > 0 ? FontWeight.bold : FontWeight.w400,
                                  ),
                                ),
                              ]
                          ),
                        ],
                      ),
                    )
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(30),
                    color: Colors.blue,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Placeholder"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(30),
                    color: Colors.blue,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(_imagePath.isNotEmpty ? _imagePath : "https://media.istockphoto.com/id/1147544807/vector/thumbnail-image-vector-graphic.jpg?s=612x612&w=0&k=20&c=rnCKVbdxqkjlcs3xH87-9gocETqpspHFXu5dIGB4wuM="),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                FilePickerResult? result = await FilePicker.platform.pickFiles(
                                  allowMultiple: true,
                                  type: FileType.image,
                                  withData: true,
                                );
                                if (result != null) {
                                  selectedFiles = result.files;

                                  for(var file in selectedFiles) {
                                    if (file.bytes != null) {
                                      String fileName = file.name;
                                      Uint8List fileBytes = file.bytes!;

                                      try {
                                        print("Hello");
                                        TaskSnapshot upload = await FirebaseStorage.instance
                                            .ref('uploads/${user?.uid}/$fileName')
                                            .putData(fileBytes);

                                        String downloadURL = await upload.ref.getDownloadURL();
                                        print("Uploaded $fileName: $downloadURL");
                                      }
                                      catch (e) {
                                        print("Failed to upload $fileName: $e");
                                      }
                                    }
                                    else{
                                      print("null");
                                    }
                                  }

                                  setState(() {
                                    loadImages();
                                  });
                                } else {
                                  print("No file selected");
                                }
                              },
                              child: Text(
                                "Upload Scans",
                                style: TextStyle(fontSize: 30),
                              )
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  carouselIndex--;
                                  if(carouselIndex<0)
                                  {
                                    carouselIndex = fileURLS.length-1;
                                  }
                                  _imagePath = fileURLS[carouselIndex];
                                  print(_imagePath);
                                });
                              },
                              child: Text(
                                "<",
                                style: TextStyle(fontSize: 30),
                              )
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  carouselIndex++;
                                  if(carouselIndex>=fileURLS.length)
                                  {
                                    carouselIndex = 0;
                                  }
                                  _imagePath = fileURLS[carouselIndex];
                                  print(_imagePath);
                                });
                              },
                              child: Text(
                                ">",
                                style: TextStyle(fontSize: 30),
                              )
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(30),
                    color: Colors.blue,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: 'Before you submit, you may fill out some ', // default text style
                            children: <TextSpan>[
                              TextSpan(text: 'additional information', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: ' below.', style: TextStyle(fontWeight: FontWeight.normal))
                            ],
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                          child: TextField(
                            controller: additionalInfoController,
                            decoration: InputDecoration(border: OutlineInputBorder()),
                            maxLines: 8,
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            text: 'After submitting, you will recieve a diagnosis and a rehab plan will be added to the ', // default text style
                            children: <TextSpan>[
                              TextSpan(text: 'Rehab page', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async{
                            await db.collection('Diagnosis').doc(user?.uid).set({
                              "Symptoms": {
                                "lHamstringPain": lHamstringPain,
                                "rHamstringPain": rHamstringPain,
                                "lQuadPain": lQuadPain,
                                "rQuadPain": rQuadPain,
                                "lKneePain": lKneePain,
                                "rKneePain": rKneePain,
                                "lCalfPain": lCalfPain,
                                "rCalfPain": rCalfPain,
                                "lAnklePain": lAnklePain,
                                "rAnklePain": rAnklePain,
                              },
                            });
                            await db.collection("AdditionalInfo").doc(user?.uid).set({
                              "Text":additionalInfoController.text,
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MyHomePage(title: "Log in"))
                            );
                          },
                          child: Text(
                            "Submit",
                            style: TextStyle(fontSize: 30),
                          )
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}