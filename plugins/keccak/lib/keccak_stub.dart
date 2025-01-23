import 'dart:typed_data';

typedef KeccakInstance = dynamic;

KeccakInstance create({int stateSize = 256 >> 3, int paddingByte = 0x1f}) {
  throw UnimplementedError();
}

void free(KeccakInstance instance) {
  throw UnimplementedError();
}

void initialize(KeccakInstance instance, int rate, int capacity, int hashBitLen,
    int delimitedSuffix) {
  throw UnimplementedError();
}

void absorb(KeccakInstance instance, Uint8List data) {
  throw UnimplementedError();
}

Future<void> absorbAsync(KeccakInstance instance, Uint8List data) async {
  throw UnimplementedError();
}

Uint8List squeeze(KeccakInstance instance, int bytesToSqueeze) {
  throw UnimplementedError();
}

Future<Uint8List> squeezeAsync(
    KeccakInstance instance, int bytesToSqueeze) async {
  throw UnimplementedError();
}

Uint8List sha3_512(Uint8List input) {
  throw UnimplementedError();
}

Future<Uint8List> sha3_512Async(Uint8List input) async {
  throw UnimplementedError();
}
