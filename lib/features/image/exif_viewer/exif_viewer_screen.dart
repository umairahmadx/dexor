import 'package:flutter/material.dart';

class ExifViewerScreen extends StatefulWidget {
  const ExifViewerScreen({super.key});

  @override
  State<ExifViewerScreen> createState() => _ExifViewerScreenState();
}

class _ExifViewerScreenState extends State<ExifViewerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EXIF Viewer')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('EXIF Viewer coming soon'),
        ),
      ),
    );
  }
}
