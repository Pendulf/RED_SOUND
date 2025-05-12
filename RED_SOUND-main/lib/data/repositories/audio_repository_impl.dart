// audio_repository_impl.dart
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/repositories/audio_repository.dart';

class AudioRepositoryImpl implements AudioRepository {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
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

  // В вашем AudioRepositoryImpl
  @override
  Future<void> playFile(File file) async {
    try {
      // Используйте flutter_sound для воспроизведения
      final player = FlutterSoundPlayer();
      await player.openPlayer();
      await player.startPlayer(
        fromURI: file.path,
        codec: Codec.mp3,
      );
    } catch (e) {
      debugPrint("Error playing file: $e");
      throw Exception("Could not play file");
    }
  }

  @override
  Future<void> stopPlaying() async {
    await _player.stopPlayer();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    _audioStreamController.close();
  }
  
}