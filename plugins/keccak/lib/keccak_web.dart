import 'dart:typed_data';

import 'keccak_dart/keccak.dart';

typedef KeccakInstance = KeccakHash;

// default to shake256 params
KeccakInstance create({int stateSize = 256 >> 3, int paddingByte = 0x1f}) {
  return KeccakHash(stateSize: stateSize, paddingByte: paddingByte);
}

void free(KeccakInstance instance) {
  // no op
}

void initialize(KeccakInstance instance, int rate, int capacity, int hashBitLen,
    int delimitedSuffix) {
  final stateSize = capacity >> 4;

  instance.stateSize = stateSize;
  instance.hashLength = stateSize;
  instance.blockLength = 200 - (stateSize << 1);

  instance.paddingByte = delimitedSuffix;

  instance.reset();
}

void absorb(KeccakInstance instance, Uint8List data) {
  instance.absorb(data);
}

Future<void> absorbAsync(KeccakInstance instance, Uint8List data) async {
  absorb(instance, data);
}

Uint8List squeeze(KeccakInstance instance, int bytesToSqueeze) {
  return instance.squeeze(bytesToSqueeze * 8);
}

Future<Uint8List> squeezeAsync(
    KeccakInstance instance, int bytesToSqueeze) async {
  return squeeze(instance, bytesToSqueeze);
}

Uint8List sha3_512(Uint8List input) {
  final instance =
      KeccakHash(stateSize: 512 >> 3, paddingByte: 0x06, outputSize: 64);
  instance.add(input);
  return instance.$finalize();
}

Future<Uint8List> sha3_512Async(Uint8List input) async {
  return sha3_512(input);
}
