import 'package:flutter/material.dart';

class SvgOptimizerScreen extends StatefulWidget {
  const SvgOptimizerScreen({super.key});

  @override
  State<SvgOptimizerScreen> createState() => _SvgOptimizerScreenState();
}

class _SvgOptimizerScreenState extends State<SvgOptimizerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SVG Optimizer')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('SVG Optimizer coming soon'),
        ),
      ),
    );
  }
}
