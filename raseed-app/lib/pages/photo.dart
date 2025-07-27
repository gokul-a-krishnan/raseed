import 'package:flutter/material.dart';
import 'package:myapp/widgets/photo_camer.dart';

class Photo extends StatefulWidget {
  const Photo({super.key});

  @override
  PhotoState createState() => PhotoState();
}

class PhotoState extends State<Photo> {
  var cameraOn = true;

  void toggleCamera() {
    setState(() {
      cameraOn = !cameraOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return cameraOn
        ? Camera(callBack: toggleCamera)
        : Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade300,
                foregroundColor: Colors.black,
              ),
              onPressed: toggleCamera,
              child: const Text("Turn Camera On"),
            ),
          );
  }
}