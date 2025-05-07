import 'dart:async';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fftea/fftea.dart';

void main() {
  runApp(const MaterialApp(home: PitchDetector()));
}

class PitchDetector extends StatefulWidget {
  const PitchDetector({super.key});
  @override
  State<PitchDetector> createState() => _PitchDetectorState();
}

class _PitchDetectorState extends State<PitchDetector> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final StreamController<Uint8List> _audioStreamController = StreamController<Uint8List>();
  final List<double> _audioBuffer = [];

  double? _detectedPitch;
  String? _detectedNote;

  final int _bufferSize = 2048;
  final int _sampleRate = 44100;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();

    // Обработка потока аудио
    _audioStreamController.stream.listen((Uint8List data) {
      final samples = _convertToPCM(data);
      _audioBuffer.addAll(samples);

      // Когда накапливается достаточно данных, запускаем анализ
      if (_audioBuffer.length >= _bufferSize) {
        final segment = _audioBuffer.sublist(0, _bufferSize);
        _audioBuffer.removeRange(0, _bufferSize);
        _analyzePitch(segment);
      }
    });
  }

  List<double> _convertToPCM(Uint8List data) {
    final List<double> result = [];
    final byteData = ByteData.sublistView(data);
    for (int i = 0; i < data.lengthInBytes; i += 2) {
      final int sample = byteData.getInt16(i, Endian.little);
      result.add(sample / 32768.0); // нормализация
    }
    return result;
  }

  void _analyzePitch(List<double> samples) {
    final fft = FFT(samples.length);
    final spectrum = fft.realFft(samples);
    final magnitudes = spectrum.magnitudes();

    int maxIndex = 0;
    double maxMagnitude = 0.0;
    for (int i = 0; i < magnitudes.length; i++) {
      if (magnitudes[i] > maxMagnitude) {
        maxMagnitude = magnitudes[i];
        maxIndex = i;
      }
    }

    final frequency = maxIndex * _sampleRate / samples.length;

    setState(() {
      _detectedPitch = frequency;
      _detectedNote = _frequencyToNote(frequency);
    });
  }

  String _frequencyToNote(double frequency) {
    final A4 = 440.0; // Частота ноты A4
    final midiNumber = 69 + (12 * log(frequency / A4) / log(2));
    final noteNames = [
      "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"
    ];
    final noteIndex = (midiNumber + 0.5).toInt() % 12;
    final octave = ((midiNumber + 0.5) / 12).toInt() - 1;

    return "${noteNames[noteIndex]}${octave + 1}";
  }

  Future<void> _startRecording() async {
    _audioBuffer.clear();
    await _recorder.startRecorder(
      toStream: _audioStreamController.sink,
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: _sampleRate,
    );
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _audioStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voice Pitch Detector")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _detectedPitch != null
                  ? "Detected pitch: ${_detectedPitch!.toStringAsFixed(2)} Hz"
                  : "Press start to detect pitch",
              style: const TextStyle(fontSize: 24),
            ),
            if (_detectedNote != null) ...[
              const SizedBox(height: 16),
              Text(
                "Detected note: $_detectedNote",
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _startRecording,
              child: const Text("Start Recording"),
            ),
            ElevatedButton(
              onPressed: _stopRecording,
              child: const Text("Stop Recording"),
            ),
          ],
        ),
      ),
    );
  }
}
