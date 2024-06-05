import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class ImageScreen extends ConsumerStatefulWidget {
  String path;

  ImageScreen(this.path, {super.key});

  @override
    
  // ignore: library_private_types_in_public_api
  _ImageScreenState createState() {
    return _ImageScreenState();
  }
}

class _ImageScreenState extends ConsumerState<ImageScreen> {


  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text('Image'),
      ),
      body: Center(
        child: Image.network(
          widget.path,
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child; // Return the actual image if loadingProgress is null
            } else {
              // Show a placeholder or loading indicator while the image is loading
              return CircularProgressIndicator(); // You can use a placeholder widget here
            }
          },
        ),
      ),
    );
  }

  // @override
  // void initState() {
  //   initialization();
  //   super.initState();
  // }

  // initialization() async {
   
  //   }
  // }


}