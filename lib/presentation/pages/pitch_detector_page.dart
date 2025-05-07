import 'package:flutter/material.dart';
import '../views/pitch_detector_view.dart';

class PitchDetectorPage extends StatelessWidget {
  const PitchDetectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voice Pitch Detector")),
      body: const PitchDetectorView(),
    );
  }
}