import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class TfliteModel extends StatefulWidget {
  const TfliteModel({Key? key}) : super(key: key);

  @override
  _TfliteModelState createState() => _TfliteModelState();
}

class _TfliteModelState extends State<TfliteModel> {
  late File _image;
  late List _results;
  bool imageSelect = false;
  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future loadModel() async {
    Tflite.close();
    String res;
    res = (await Tflite.loadModel(
        model: "assets/model.tflite", labels: "assets/labels.txt"))!;
    print("Models loading status: $res");
  }

  Future imageClassification(File image) async {
    final List? recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _results = recognitions!;
      _image = image;
      imageSelect = true;
    });
    if (_results.first['confidence'] <= 0.6) {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("DOGS BREED IDENTIFICATIONS"),
        ),
        body: ListView(
          children: [
            (imageSelect)
                ? Container(
                    margin: const EdgeInsets.all(10),
                    child: Image.file(_image),
                  )
                : Container(
                    margin: const EdgeInsets.all(10),
                    child: const Opacity(
                      opacity: 0.8,
                      child: Center(
                        child: Text("No image selected"),
                      ),
                    ),
                  ),
            SingleChildScrollView(
              child: (imageSelect)
                  ? Card(
                      child: Container(
                        margin: EdgeInsets.all(10),
                        child: (_results[0]['confidence'] < 0.74)
                            ? Text('accuracy too low')
                            : Text(
                                "${_results[0]['label']} - ${_results[0]['confidence'].toStringAsFixed(2)}",
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 20),
                              ),
                      ),
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: 60,
                        ),
                        Column(
                          children: [
                            InkWell(
                              onTap: cameraImage,
                              child: Container(
                                height: 180,
                                width: 180,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(
                                      60.0,
                                    ),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromARGB(136, 245, 239, 156),
                                      blurRadius: 5.0,
                                      spreadRadius: 20.0,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 100,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 90,
                            ),
                            InkWell(
                              onTap: pickImage,
                              child: Container(
                                height: 180,
                                width: 180,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(
                                      60.0,
                                    ),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromARGB(136, 156, 235, 245),
                                      blurRadius: 5.0,
                                      spreadRadius: 20.0,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.photo,
                                  size: 100,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            )
          ],
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        // floatingActionButton: FloatingActionButton(
        //   onPressed: pickImage,
        //   tooltip: "Pick Image",
        //   child: const Icon(Icons.image),
        // ),
      ),
    );
  }

  Future pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    _image = File(pickedFile!.path);
    imageClassification(_image);
  }

  Future cameraImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    _image = File(pickedFile!.path);
    imageClassification(_image);
  }
}
