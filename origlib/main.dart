import 'package:flutter/material.dart';
import 'package:my_app/scanner_screen.dart';
import 'package:image_picker/image_picker.dart';
/*
void main() {
  runApp(const MyApp());
}*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ObjectDetectionScreen extends StatefulWidget {
  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  Interpreter? _interpreter;
  late List<String> _labels;
  late img.Image _inputImage;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/ssd_mobilenet.tflite');
      await loadLabels();
    } catch (e) {
      debugPrint('Error loading model: $e');
    }
  }

  Future<void> loadLabels() async {
    final labelData = await rootBundle.loadString('assets/models/labels.txt');
    _labels = labelData.split('\n');
  }

  Future<void> runObjectDetection() async {
    final preprocessedImage = preprocessImage(_inputImage);
    
    final output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);

    _interpreter!.run(preprocessedImage, output);

    final detectionResults = output[0];

    // Process the detection results and display them as desired
    for (int i = 0; i < detectionResults.length; i++) {
      final label = _labels[i];
      final confidence = detectionResults[i];

      debugPrint('Label: $label, Confidence: $confidence');
    }
  }

  img.Image preprocessImage(img.Image image) {
    final resizedImage = img.copyResize(image, width: 300, height: 300);
    //final normalizedImage = resizedImage.convert(format: img.ColorRgb8(100,100,100));
    return resizedImage;
  }

  void selectImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final file = File(pickedImage.path);
      final bytes = await file.readAsBytes();

      setState(() {
        _inputImage = img.decodeImage(bytes)!;
      });

      runObjectDetection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Object Detection'),
      ),
      body: Center(
        child: _inputImage != null
            ? Image.memory(img.encodePng(_inputImage))
            : Text('No image selected'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: selectImage,
        child: Icon(Icons.image),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScannerScreen(),
    );
  }
}
