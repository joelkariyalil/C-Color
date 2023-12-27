import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page Demo',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
      );

      await _controller.initialize();
    } catch (e) {
      // Handle errors during initialization
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_controller),
                Center(
                  child: CustomPaint(
                    painter: PlusMarkPainter(),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            // Handle errors during initialization
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          } else {
            // Show a loading indicator while waiting for the camera to initialize
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}



class PlusMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {

    final Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3.0;

    final Paint transparentPaint = Paint()
      ..color = Colors.transparent
      ..strokeWidth = 3.0;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double farX = 60.0;
    final double nearX = 4.0;
    
    // Draw horizontal line
    canvas.drawLine(Offset(centerX - farX, centerY), Offset(centerX - nearX, centerY), paint);
    canvas.drawLine(Offset(centerX - nearX, centerY), Offset(centerX + nearX, centerY), transparentPaint);
    canvas.drawLine(Offset(centerX + nearX, centerY), Offset(centerX + farX, centerY), paint);

    // Draw vertical line
    canvas.drawLine(Offset(centerX, centerY - farX), Offset(centerX, centerY - nearX), paint);
    canvas.drawLine(Offset(centerX, centerY - nearX), Offset(centerX, centerY + nearX), transparentPaint);
    canvas.drawLine(Offset(centerX, centerY + nearX), Offset(centerX, centerY + farX),paint);
    }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
