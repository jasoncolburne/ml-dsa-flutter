import 'dart:typed_data';

import 'package:keccak/keccak.dart' as keccak;

// ignore: camel_case_types
class SHA3_512 {
  SHA3_512();

  Uint8List digest(Uint8List input) {
    return keccak.sha3_512(input);
  }
}
