import 'dart:math';
import 'package:fftea/fftea.dart';
import '../../domain/entities/pitch_result.dart';
import '../../domain/usecases/detect_pitch.dart';

class FFTPitchDetector implements PitchDetector {
  @override
  PitchResult detect(List<double> samples, int sampleRate) {
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

    final frequency = maxIndex * sampleRate / samples.length;
    final note = _frequencyToNote(frequency);
    
    return PitchResult(frequency, note);
  }

  String _frequencyToNote(double frequency) {
    final A4 = 440.0;
    final midiNumber = 69 + (12 * log(frequency / A4) / log(2));
    final noteNames = [
      "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"
    ];
    final noteIndex = (midiNumber + 0.5).toInt() % 12;
    final octave = ((midiNumber + 0.5) / 12).toInt() - 1;

    return "${noteNames[noteIndex]}${octave + 1}";
  }
}