import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:my_app/RunModelByImageDemo.dart';
import 'package:my_app/RunModelByCameraDemo.dart';

Future<void> main() async {
  runApp(const ChooseDemo());
}

class ChooseDemo extends StatefulWidget {
  
  const ChooseDemo({Key? key}) : super(key: key);

  @override
  State<ChooseDemo> createState() => _ChooseDemoState();
}

class _ChooseDemoState extends State<ChooseDemo> {

  late FlutterVision _vision;
  
  @override
  void initState() {
    super.initState();
    _vision = FlutterVision();
  }

  
  @override
  void dispose() async {
    super.dispose();
    await _vision.closeTesseractModel();
    await _vision.closeYoloModel();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pytorch Mobile Example'),
        ),
        body: Builder(builder: (context) {
          return Center(
            child: Column(
              children: [
                TextButton(
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RunModelByCameraDemo(vision: _vision)),
                    )
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    "Run Model with Camera",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RunModelByImageDemo(vision: _vision)),
                    )
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    "Run Model with Image",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}