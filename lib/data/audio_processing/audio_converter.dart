import 'dart:typed_data';

class AudioConverter {
  static List<double> convertToPCM(Uint8List data) {
    final List<double> result = [];
    final byteData = ByteData.sublistView(data);
    for (int i = 0; i < data.lengthInBytes; i += 2) {
      final int sample = byteData.getInt16(i, Endian.little);
      result.add(sample / 32768.0);
    }
    return result;
  }
}