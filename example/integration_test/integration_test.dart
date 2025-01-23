// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';

import 'package:ml_dsa/ml_dsa.dart';

import 'kat_MLDSA_44_det_pure.dart';
import 'kat_MLDSA_65_det_pure.dart';
import 'kat_MLDSA_87_det_pure.dart';

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
  if (kIsWeb) {
    print(
        'service worker not implemented on web, wait a while for results (a minute)');
  } else {
    print('compute isolate not used, wait a few seconds for results');
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Map<String, bool?> results = {
    'ML-DSA-44': null,
    'ML-DSA-65': null,
    'ML-DSA-87': null,
  };

  @override
  void initState() {
    Future.microtask(() async {
      final result44 =
          await testMLDSAKAT(MLDSA44Parameters(), ML_DSA_44_TestVectors);
      setState(() {
        results['ML-DSA-44'] = result44;
      });

      final result65 =
          await testMLDSAKAT(MLDSA65Parameters(), ML_DSA_65_TestVectors);
      setState(() {
        results['ML-DSA-65'] = result65;
      });

      final result87 =
          await testMLDSAKAT(MLDSA87Parameters(), ML_DSA_87_TestVectors);
      setState(() {
        results['ML-DSA-87'] = result87;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ML-DSA KAT (Pure/Deterministic)'),
        ),
        body: Column(
          children: results.keys.map((variant) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(variant),
                SizedBox(width: 24),
                Text(results[variant] == null
                    ? '...'
                    : results[variant]!
                        ? 'Success!'
                        : 'Failure.'),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
