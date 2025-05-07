import 'dart:typed_data';

abstract class AudioRepository {
  Future<void> startRecording();
  Future<void> stopRecording();
  Stream<Uint8List> get audioStream;
  void dispose();
}