// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hex/hex.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ml_dsa/ml_dsa.dart';
import 'package:ml_dsa/async.dart';

import '../kat/kat_MLDSA_44_det_pure.dart';
import '../kat/kat_MLDSA_65_det_pure.dart';
import '../kat/kat_MLDSA_87_det_pure.dart';

Future<bool> testMLDSAKAT(
    ParameterSet params, List<Map<String, String>> katVectors) async {
  final dsa = MLDSA(params);

  for (final vector in katVectors) {
    final seed = Uint8List.fromList(HEX.decode(vector['Seed']!));
    final (pk, sk) = await dsa.keyGenWithSeedAsync(seed);

    if (vector['PublicKey'] != HEX.encode(pk)) {
      print('bad pk:');
      print(HEX.encode(pk));
      print('expected:');
      print(vector['PublicKey']);
      return false;
    }

    if (vector['PrivateKey'] != HEX.encode(sk)) {
      print('bad sk:');
      print(HEX.encode(sk));
      print('expected:');
      print(vector['PrivateKey']);
      return false;
    }

    final message = Uint8List.fromList(HEX.decode(vector['Message']!));
    final ctx = Uint8List.fromList(HEX.decode(vector['Context']!));

    final sig = await dsa.signDeterministicallyAsync(sk, message, ctx);
    final Uint8List sm = Uint8List(sig.length + message.length);
    sm.setRange(0, sig.length, sig);
    sm.setRange(sig.length, sm.length, message);

    if (vector['Signature'] != HEX.encode(sm)) {
      print('bad sm (${sig.length}/${sm.length}):');
      print(HEX.encode(sm));
      print('expected:');
      print(vector['Signature']);
      return false;
    }
  }

  return true;
}

void main() async {
  group('KAT Vectors: ', () {
    setUpAll(() {
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    });

    test('ML-DSA-44', () async {
      final params = MLDSA44Parameters();
      expect(await testMLDSAKAT(params, ML_DSA_44_TestVectors), true);
    });

    test('ML-DSA-65', () async {
      final params = MLDSA65Parameters();
      expect(await testMLDSAKAT(params, ML_DSA_65_TestVectors), true);
    });

    test('ML-DSA-87', () async {
      final params = MLDSA87Parameters();
      expect(await testMLDSAKAT(params, ML_DSA_87_TestVectors), true);
    });
  });
}
