// pitch_detector_provider.dart
import 'dart:async';
import 'dart:io';
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
  File? _selectedFile;
  bool _isFileMode = false;
  bool _isAnalyzing = false;
  bool _isPlaying = false;

  PitchDetectorProvider({
    required this.audioRepository,
    required this.pitchDetector,
  });

  double? get pitch => _pitch;
  String? get note => _note;
  File? get selectedFile => _selectedFile;
  bool get isFileMode => _isFileMode;
  bool get isAnalyzing => _isAnalyzing;
  bool get isPlaying => _isPlaying;

  void selectFile(File file) {
    _selectedFile = file;
    _isFileMode = true;
    _pitch = null;
    _note = null;
    notifyListeners();
  }

  void unselectFile() {
    _selectedFile = null;
    _isFileMode = false;
    notifyListeners();
  }

  Future<void> startRecording() async {
    if (_isFileMode) {
      await _analyzeFile();
      return;
    }
    
    _audioBuffer.clear();
    _pitch = null;
    _note = null;
    notifyListeners();
    
    _audioSubscription = audioRepository.audioStream.listen(_processAudio);
    await audioRepository.startRecording();
  }

  Future<void> stopRecording() async {
    await _audioSubscription?.cancel();
    await audioRepository.stopRecording();
  }

  Future<void> togglePlayback() async {
    if (_selectedFile == null) return;
    
    if (_isPlaying) {
      await audioRepository.stopPlaying();
      _isPlaying = false;
    } else {
      await audioRepository.playFile(_selectedFile!);
      _isPlaying = true;
    }
    notifyListeners();
  }

  Future<void> _analyzeFile() async {
    if (_selectedFile == null) return;

    _isAnalyzing = true;
    notifyListeners();

    try {
      final bytes = await _selectedFile!.readAsBytes();
      final samples = AudioConverter.convertToPCM(bytes);
      _audioBuffer.clear();
      _audioBuffer.addAll(samples);

      for (var i = 0; i < _audioBuffer.length; i += bufferSize) {
        if (!_isAnalyzing) break;
        
        final end = i + bufferSize < _audioBuffer.length 
            ? i + bufferSize 
            : _audioBuffer.length;
        final segment = _audioBuffer.sublist(i, end);
        
        final result = pitchDetector.detect(segment, sampleRate);
        _pitch = result.frequency;
        _note = result.note;
        notifyListeners();
        
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
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