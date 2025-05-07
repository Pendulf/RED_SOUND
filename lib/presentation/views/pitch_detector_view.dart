import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pitch_detector_provider.dart';

class PitchDetectorView extends StatelessWidget {
  const PitchDetectorView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PitchDetectorProvider>();
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            provider.pitch != null
                ? "Detected pitch: ${provider.pitch!.toStringAsFixed(2)} Hz"
                : "Press start to detect pitch",
            style: const TextStyle(fontSize: 24),
          ),
          if (provider.note != null) ...[
            const SizedBox(height: 16),
            Text(
              "Detected note: ${provider.note}",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: provider.startRecording,
            child: const Text("Start Recording"),
          ),
          ElevatedButton(
            onPressed: provider.stopRecording,
            child: const Text("Stop Recording"),
          ),
        ],
      ),
    );
  }
}