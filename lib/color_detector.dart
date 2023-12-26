import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ColorDetector extends StatefulWidget {
  final GlobalKey cameraKey;

  const ColorDetector({Key? key, required this.cameraKey}) : super(key: key);

  @override
  _ColorDetectorState createState() => _ColorDetectorState();
}

class _ColorDetectorState extends State<ColorDetector> {
  GlobalKey boundaryKey = GlobalKey();
  late ui.Image image;

  Future<void> _captureAndAnalyzeImage() async {
    RenderRepaintBoundary? boundary =
    boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      // Handle the case where the boundary is null (e.g., widget is not yet laid out)
      return;
    }
    ui.Image boundaryImage = await boundary.toImage();
    ByteData? byteData = await boundaryImage.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      Uint8List pngBytes = byteData.buffer.asUint8List();
      ui.decodeImageFromList(pngBytes, (decodedImage) {
        setState(() {
          image = decodedImage!;
          _analyzeColor();
        });
      });
    }
  }

  void _analyzeColor() async {
    if (image != null) {
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData != null) {
        Uint32List buffer = byteData.buffer.asUint32List();
        if (buffer.isNotEmpty) {
          Color centerPixelColor = Color(buffer[0]);

          int red = centerPixelColor.red;
          int green = centerPixelColor.green;
          int blue = centerPixelColor.blue;

          print("RGB: ($red, $green, $blue)");
        } else {
          print("Buffer is empty");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Color Detector"),
      ),
      body: Center(
        child: RepaintBoundary(
          key: boundaryKey,
          child: Container(
            width: 5,
            height: 5,
            color: Colors.transparent, // Set the color you want to detect
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _captureAndAnalyzeImage,
        tooltip: 'Capture Color',
        child: Icon(Icons.camera),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ColorDetector(cameraKey: GlobalKey()),
  ));
}
