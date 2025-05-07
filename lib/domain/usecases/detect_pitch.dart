import '../entities/pitch_result.dart';

abstract class PitchDetector {
  PitchResult detect(List<double> samples, int sampleRate);
}