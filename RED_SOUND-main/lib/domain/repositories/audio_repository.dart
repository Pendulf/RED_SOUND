// audio_repository.dart
import 'dart:typed_data';
import 'dart:io';

abstract class AudioRepository {
  Future<void> startRecording();
  Future<void> stopRecording();
  Future<void> playFile(File file);
  Future<void> stopPlaying();
  Stream<Uint8List> get audioStream;
  void dispose();
}