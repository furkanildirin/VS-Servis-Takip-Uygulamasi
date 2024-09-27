import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenImagePage extends StatelessWidget {
  final File imageFile;

  const FullScreenImagePage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full Screen Image',style: TextStyle(fontWeight: FontWeight.bold,)),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Image.file(
          imageFile,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
