import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:image/image.dart' as img;

import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:my_app/PolygonPainter.dart';

class RunModelByImageDemo extends StatefulWidget {
  final FlutterVision vision;
  const RunModelByImageDemo({Key? key,required this.vision}) : super(key: key);

  @override
  _RunModelByImageDemoState createState() => _RunModelByImageDemoState();
}

class _RunModelByImageDemoState extends State<RunModelByImageDemo> {
  
  List<Map<String, dynamic>>? yoloResults = [];
 
  bool isLoaded = false;
  bool isDetecting = false;

  late FlutterVision vision; // YOLO
  FlutterTts flutterTts = FlutterTts(); // TTS

  File? imageFile;
  int imageHeight = 1;
  int imageWidth = 1;
  
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _busy = true;
    vision = FlutterVision(); // YOLO
    initTTS(); // TTS

    init();    
  }

 Future<void> initTTS() async { // TTS
    await flutterTts.setLanguage("en-US"); // Set the language you want
    await flutterTts.setSpeechRate(1.0); // Adjust speech rate (1.0 is normal)
    await flutterTts.setVolume(1.0); // Adjust volume (0.0 to 1.0)
    await flutterTts.setPitch(1.0); // Adjust pitch (1.0 is normal)
  }

  Future<void> loadYoloModel() async {
    await vision.loadYoloModel(
        //labels: 'assets/best-v8.txt',
        //modelPath: 'assets/best_float32.tflite', //---------> this is for object detection
        labels: 'assets/best_segmentation.txt',
        modelPath: 'assets/best_segmentation_float32.tflite',        
        //modelVersion: "yolov8", //---------> this is for object detection
        modelVersion: "yolov8seg",
        quantization: false,
        numThreads: 2);
    setState(() {
      isLoaded = true;      
    });
  }

  init() async {
    debugPrint("init is called..");
    loadYoloModel().then((value) {
      setState(() {
        isLoaded = true;
        isDetecting = false;
      });
    });
    debugPrint("init is done..");
  }

  selectFromImagePicker() async {
    debugPrint("selectFromImagePicker is called..");
    yoloResults!.clear();
    final ImagePicker picker = ImagePicker();
    // Capture a photo
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      setState(() {
        imageFile = File(photo.path);
      });
    }
    debugPrint("selectFromImagePicker is done..");
  }

  yoloOnImage() async {
  debugPrint("yoloOnImage is called..");
  yoloResults!.clear();
  Uint8List byte = await imageFile!.readAsBytes();
  final image = await decodeImageFromList(byte);
    imageHeight = image.height;
    imageWidth = image.width;
    final result = await widget.vision.yoloOnImage(
        bytesList: byte,
        imageHeight: image.height,
        imageWidth: image.width,
        iouThreshold: 0.8,
        confThreshold: 0.4,
        classThreshold: 0.5);
    if (result.isNotEmpty) {
      setState(() {
        yoloResults = result;
      });
    }
    debugPrint("yoloOnImage is done..${yoloResults}");
  }  

  Future<void> speak(String text) async {
    debugPrint("speak is called..");
      await flutterTts.speak(text); // TTS
      debugPrint("speak is done..");
  }

  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
     debugPrint("displayBoxesAroundRecognizedObjects is called..1");
    if (yoloResults!.isEmpty) return [];
    debugPrint("displayBoxesAroundRecognizedObjects is called..2");
    double factorX = screen.width / (imageWidth);
    double imgRatio = imageWidth / imageHeight;
    double newWidth = imageWidth * factorX;
    double newHeight = newWidth / imgRatio;
    double factorY = newHeight / (imageHeight);

    double pady = (screen.height - newHeight) / 2;

    Color colorPick = const Color.fromARGB(255, 50, 233, 30);
    return yoloResults!.map((result) {
      speak("${result['tag']}");
      debugPrint("displayBoxesAroundRecognizedObjects is end..1");
      return Positioned(
        
        left: result["box"][0] * factorX,
        top: result["box"][1] * factorY + pady,
        width: (result["box"][2] - result["box"][0]) * factorX,
        height: (result["box"][3] - result["box"][1]) * factorY,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: Colors.pink, width: 2.0),
          ),
          child: Text(
            "${result['tag']} ${(result['box'][4] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = colorPick,
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
  }

//Use this for segmentation analysis.
List<Widget> displaySegmentaionBoxesAroundRecognizedObjects(Size screen) {
  debugPrint("displaySegmentaionBoxesAroundRecognizedObjects is called..1");
    if (yoloResults!.isEmpty) return [];
    debugPrint("displaySegmentaionBoxesAroundRecognizedObjects is called..2");
    double factorX = screen.width / (imageWidth);
    double imgRatio = imageWidth / imageHeight;
    double newWidth = imageWidth * factorX;
    double newHeight = newWidth / imgRatio;
    double factorY = newHeight / (imageHeight);

    double pady = (screen.height - newHeight) / 2;

    Color colorPick = const Color.fromARGB(255, 50, 233, 30);
    return yoloResults!.map((result) {
      debugPrint("displaySegmentaionBoxesAroundRecognizedObjects is called..3");
      return Stack(children: [
        Positioned(
          left: result["box"][0] * factorX,
          top: result["box"][1] * factorY + pady,
          width: (result["box"][2] - result["box"][0]) * factorX,
          height: (result["box"][3] - result["box"][1]) * factorY,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              border: Border.all(color: Colors.pink, width: 2.0),
            ),
            child: Text(
              "${result['tag']} ${(result['box'][4] * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                background: Paint()..color = colorPick,
                color: Colors.white,
                fontSize: 18.0,
              ),
            ),
          ),
        ),
        Positioned(
            left: result["box"][0] * factorX,
            top: result["box"][1] * factorY + pady,
            width: (result["box"][2] - result["box"][0]) * factorX,
            height: (result["box"][3] - result["box"][1]) * factorY,
            child: CustomPaint(
              painter: PolygonPainter(
                  points: (result["polygons"] as List<dynamic>).map((e) {
                Map<String, double> xy = Map<String, double>.from(e);
                xy['x'] = (xy['x'] as double) * factorX;
                xy['y'] = (xy['y'] as double) * factorY;
                return xy;
              }).toList()),
            )),
      ]);
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (!isLoaded) {
      return const Scaffold(
        body: Center(
          child: Text("Model not loaded, waiting for it"),
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        imageFile != null ? Image.file(imageFile!) : const SizedBox(),
        Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: selectFromImagePicker,
                child: const Text("Pick image"),
              ),
              ElevatedButton(
                onPressed: yoloOnImage,
                child: const Text("Detect"),
              )
            ],
          ),
        ),
        //...displayBoxesAroundRecognizedObjects(size),
        ...displaySegmentaionBoxesAroundRecognizedObjects(size),
      ],
    );
  }
}