import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:myapp/pages/confirm_photo.dart';

class Camera extends StatefulWidget {
  final VoidCallback callBack;
  const Camera({ super.key, required this.callBack});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late Future<CameraController> controller;

  @override
  void initState() {
    super.initState();
    controller = initializeController();
  }

  Future<CameraController> initializeController() async {
    final cameras = await availableCameras();
    final controller = CameraController(cameras[0], ResolutionPreset.max);
    await controller.initialize();
    await controller.setFlashMode(FlashMode.off);
    return controller;
  }

  Future<void> takePicture(BuildContext context) async {
    final XFile file = await controller.then((value) => value.takePicture());
    if (!context.mounted) return;
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmPhoto(file: File(file.path)),
        ));
    widget.callBack();
  }

  @override
  void dispose() {
    controller.then((value) => value.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CameraController>(
      future: controller,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CameraPreview(
            snapshot.data!,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: FloatingActionButton(
                  backgroundColor: Colors.green.shade300,
                  foregroundColor: Colors.black,
                  onPressed: () => takePicture(context),
                  child: const Icon(Icons.camera_alt),
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}