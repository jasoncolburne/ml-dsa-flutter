import 'dart:typed_data';

import 'package:keccak/keccak.dart' as keccak;

class IncrementalSHAKE {
  final int bitLength;

  late keccak.KeccakInstance _shake;

  IncrementalSHAKE(this.bitLength) {
    _shake = keccak.create();
    // necessary to initialize C implementation
    reset();
  }

  void destroy() {
    keccak.free(_shake);
  }

  void absorb(Uint8List input) {
    keccak.absorb(_shake, input);
  }

  Uint8List squeeze(int outputLength) {
    return keccak.squeeze(_shake, outputLength);
  }

  void reset() {
    switch (bitLength) {
      case 128:
        keccak.initialize(_shake, 1344, 256, 0, 0x1f);
      case 256:
        keccak.initialize(_shake, 1088, 512, 0, 0x1f);
      default:
        throw Exception('programmer error (invalid bitlength)');
    }
  }
}
