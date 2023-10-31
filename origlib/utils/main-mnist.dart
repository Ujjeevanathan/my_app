import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  final picker = ImagePicker();
  bool _loading = true;  
  List? _output;
  String? _prediction;

void _updatePrediction(String prediction) {
    setState(() {
      _prediction = prediction;
    });
  }

@override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/models/mnist_float16.tflite',
        labels: 'assets/models/mnist_float32.txt');
  }

  @override
  void dispose() {
    super.dispose();
  }

  //Image Picker function to get image from gallery
  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });

    detectImage(_image!);
  }

  //Image Picker function to get image from camera
  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
    detectImage(_image!);
  }

  detectImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.6,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      _output = output!;
      _loading = false;
    });    
  }

  //Show options to get image from camera or gallery
  Future showOptions() async {
    _prediction = '';
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text('Photo Gallery'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from gallery
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Camera'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

    return Scaffold(
      appBar: AppBar(
        title: Text('MNIST PlayGround'),
      ),
      body: Column(
        children: [
          TextButton(
            child: Text('Select Image'),
            onPressed: showOptions,
          ),
          Center(
            child: _image == null ? Text('No Image selected') : Image.file(_image!),
          ),
          Column(
        mainAxisSize: MainAxisSize.min,        
        children: <Widget>[
          ElevatedButton(
            style: style,
            onPressed: _image == null ? null : (() {  
              _updatePrediction('${_output![0]['label']}');  
              debugPrint('${_output![0]['label']}');   
            }),
            child: _image == null ? const Text('Disabled') : const Text('Predict'),
          ),  
          Text(
              _prediction == null ? '': _prediction!,            
              style: Theme.of(context).textTheme.headlineMedium,
            ),             
        ],
        ),
        ],
      ),
    );
  }
}