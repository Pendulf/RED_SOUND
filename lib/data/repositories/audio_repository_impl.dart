import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/repositories/audio_repository.dart';

class AudioRepositoryImpl implements AudioRepository {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final StreamController<Uint8List> _audioStreamController = StreamController<Uint8List>();

  @override
  Stream<Uint8List> get audioStream => _audioStreamController.stream;

  @override
  Future<void> startRecording() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
    await _recorder.startRecorder(
      toStream: _audioStreamController.sink,
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: 44100,
    );
  }

  @override
  Future<void> stopRecording() async {
    await _recorder.stopRecorder();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _audioStreamController.close();
  }
}