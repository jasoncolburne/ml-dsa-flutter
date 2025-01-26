import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ml_dsa/ml_dsa.dart';
import 'package:ml_dsa/async.dart';

Future<bool> testMLDSARoundTrip(
  ParameterSet params,
  int skLen,
  int pkLen,
  int sigLen,
) async {
  final MLDSA dsa = MLDSA(params);

  final (pk, sk) = await dsa.keyGenAsync();

  if (pkLen != pk.length) {
    print('unexpected pk length: ${pk.length}');
    return false;
  }

  if (skLen != sk.length) {
    print('unexpected sk length: ${sk.length}');
    return false;
  }

  final msg = utf8.encode("message");
  final ctx = utf8.encode("context");

  final sig = await dsa.signAsync(sk, msg, ctx);

  if (sigLen != sig.length) {
    print('unexpected sk length: ${sig.length}');
    return false;
  }

  if (!await dsa.verifyAsync(pk, msg, sig, ctx)) {
    print("verification FAILED");
    return false;
  }

  final Uint8List pkPrime = mutate(pk);
  final Uint8List msgPrime = mutate(msg);
  final Uint8List sigPrime = mutate(sig);
  final Uint8List ctxPrime = mutate(ctx);

  if (await dsa.verifyAsync(pkPrime, msg, sig, ctx)) {
    print("verification SUCCEEDED incorrectly for a mutated pk");
    return false;
  }

  if (await dsa.verifyAsync(pk, msgPrime, sig, ctx)) {
    print("verification SUCCEEDED incorrectly for a mutated message");
    return false;
  }

  if (await dsa.verifyAsync(pk, msg, sigPrime, ctx)) {
    print("verification SUCCEEDED incorrectly for a mutated signature");
    return false;
  }

  if (await dsa.verifyAsync(pk, msg, sig, ctxPrime)) {
    print("verification SUCCEEDED incorrectly for a mutated context");
    return false;
  }

  return true;
}

Uint8List mutate(Uint8List input) {
  final data = Uint8List.fromList(input);
  final offset = Random.secure().nextInt(data.length);
  data[offset] ^= 0x01;
  return data;
}

void main() {
  group('Round Trip: ', () {
    setUpAll(() {
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    });

    test('ML-DSA-44', () async {
      final params = MLDSA44Parameters();
      expect(await testMLDSARoundTrip(params, 2560, 1312, 2420), true);
    });

    test('ML-DSA-65', () async {
      final params = MLDSA65Parameters();
      expect(await testMLDSARoundTrip(params, 4032, 1952, 3309), true);
    });

    test('ML-DSA-87', () async {
      final params = MLDSA87Parameters();
      expect(await testMLDSARoundTrip(params, 4896, 2592, 4627), true);
    });
  });
}
