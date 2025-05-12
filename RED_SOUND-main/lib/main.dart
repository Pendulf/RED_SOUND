// main.dart
import "dart:io";
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

import 'data/audio_processing/pitch_detector_impl.dart';
import 'data/repositories/audio_repository_impl.dart';
import 'domain/repositories/audio_repository.dart';
import 'domain/usecases/detect_pitch.dart';
import 'presentation/pages/pitch_detector_page.dart';
import 'presentation/providers/pitch_detector_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize audio files directory
  final appDir = await getApplicationDocumentsDirectory();
  final audioDir = Directory('${appDir.path}/audio');
  if (!await audioDir.exists()) {
    await audioDir.create(recursive: true);
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<AudioRepository>(create: (_) => AudioRepositoryImpl()),
        Provider<PitchDetector>(create: (_) => FFTPitchDetector()),
        ChangeNotifierProvider(
          create: (context) => PitchDetectorProvider(
            audioRepository: context.read<AudioRepository>(),
            pitchDetector: context.read<PitchDetector>(),
          ),
        ),
      ],
      child: const MaterialApp(
        title: 'Voice Pitch Detector',
        home: PitchDetectorPage(),
      ),
    ),
  );
}