// ignore_for_file: file_names

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller; // Camera Controller
  //Future to wait until camera initializes
  late Future<void> _initializeControllerFuture;
  int selectedCamera = 0;
  List<File> capturedImages = [];

  void initializeCamera(int cameraIndex) async {
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.cameras[cameraIndex],
      // Define the resolution to use.
      ResolutionPreset.medium,
    );
    // Initialize the controller. Returns Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void initState() {
    initializeCamera(selectedCamera);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          camPreview(),
          const Spacer(),
          Row(children: [
            //Switch camera
            IconButton(
              onPressed: () => changeCamera(),
              icon: const Icon(Icons.switch_camera_rounded, color: Colors.white),
            ),

            // Capture Button
            GestureDetector(
              onTap: () => capturedImage(),
              child: Container(
                  height: 60,
                  width: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  )),
            ),

            // Gallery Button
            GestureDetector(
              onTap: () => galleryButton(),
            )
          ])
        ],
      ),
    );
  }

  FutureBuilder<void> camPreview() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        // If future is complete, display the camera preview
        if (snapshot.connectionState == ConnectionState.done) {
          return CameraPreview(_controller);
        }
        // else, display a circular loading indicator
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  capturedImage() async {
    await _initializeControllerFuture; //Make sure camera is initialized
    var xFile = await _controller.takePicture();
    setState(() {
      capturedImages.add(File(xFile.path));
    });
  }

  changeCamera() {
    if (widget.cameras.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No secondary camera found'),
        duration: Duration(seconds: 2),
      ));
    }
    setState(() {
      selectedCamera = selectedCamera == 0 ? 1 : 0; //Switch camera
      initializeCamera(selectedCamera);
    });
  }

  galleryButton() {}
}
