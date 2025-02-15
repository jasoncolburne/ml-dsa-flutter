import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ml_dsa_example/sw_client.dart';

Future<bool> testRoundtrip(int strength) async {
  final (pk, sk) = await MLDSASWClient.keyGen(strength);
  final msg = utf8.encode("message");
  final ctx = utf8.encode("context");

  final sig = await MLDSASWClient.sign(strength, sk, msg, ctx);

  if (!await MLDSASWClient.verify(strength, pk, msg, sig, ctx)) {
    print("verification FAILED");
    return false;
  }

  final Uint8List pkPrime = mutate(pk);
  final Uint8List msgPrime = mutate(msg);
  final Uint8List sigPrime = mutate(sig);
  final Uint8List ctxPrime = mutate(ctx);

  if (await MLDSASWClient.verify(strength, pkPrime, msg, sig, ctx)) {
    print("verification SUCCEEDED incorrectly for a mutated pk");
    return false;
  }

  if (await MLDSASWClient.verify(strength, pk, msgPrime, sig, ctx)) {
    print("verification SUCCEEDED incorrectly for a mutated message");
    return false;
  }

  if (await MLDSASWClient.verify(strength, pk, msg, sigPrime, ctx)) {
    print("verification SUCCEEDED incorrectly for a mutated signature");
    return false;
  }

  if (await MLDSASWClient.verify(strength, pk, msg, sig, ctxPrime)) {
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

void main() async {
  await MLDSASWClient.initialize();

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
      final result44 = await testRoundtrip(44);
      setState(() {
        results['ML-DSA-44'] = result44;
      });

      final result65 = await testRoundtrip(65);
      setState(() {
        results['ML-DSA-65'] = result65;
      });

      final result87 = await testRoundtrip(87);
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
          title: const Text('ML-DSA Roundtrip'),
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
