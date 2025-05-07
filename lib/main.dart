import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/audio_processing/pitch_detector_impl.dart';
import 'data/repositories/audio_repository_impl.dart';
import 'domain/repositories/audio_repository.dart';
import 'domain/usecases/detect_pitch.dart';
import 'presentation/pages/pitch_detector_page.dart';
import 'presentation/providers/pitch_detector_provider.dart';

void main() {
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
      child: const MaterialApp(home: PitchDetectorPage()),
    ),
  );
}