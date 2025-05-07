import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../domain/repositories/audio_repository.dart';
import '../../domain/usecases/detect_pitch.dart';
import '../../data/audio_processing/audio_converter.dart';

class PitchDetectorProvider extends ChangeNotifier {
  final AudioRepository audioRepository;
  final PitchDetector pitchDetector;
  
  static const int bufferSize = 2048;
  static const int sampleRate = 44100;
  
  final List<double> _audioBuffer = [];
  double? _pitch;
  String? _note;
  StreamSubscription? _audioSubscription;

  PitchDetectorProvider({
    required this.audioRepository,
    required this.pitchDetector,
  });

  double? get pitch => _pitch;
  String? get note => _note;

  void startRecording() {
    _audioBuffer.clear();
    _pitch = null;
    _note = null;
    notifyListeners();
    
    _audioSubscription = audioRepository.audioStream.listen(_processAudio);
    audioRepository.startRecording();
  }

  Future<void> stopRecording() async {
    await _audioSubscription?.cancel();
    await audioRepository.stopRecording();
  }

  void _processAudio(Uint8List data) {
    final samples = AudioConverter.convertToPCM(data);
    _audioBuffer.addAll(samples);

    if (_audioBuffer.length >= bufferSize) {
      final segment = _audioBuffer.sublist(0, bufferSize);
      _audioBuffer.removeRange(0, bufferSize);
      
      final result = pitchDetector.detect(segment, sampleRate);
      _pitch = result.frequency;
      _note = result.note;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _audioSubscription?.cancel();
    audioRepository.dispose();
    super.dispose();
  }
}