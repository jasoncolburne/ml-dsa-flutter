import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ml_dsa/ml_dsa.dart';

Future<bool> testRoundtrip(ParameterSet params) async {
  final MLDSA dsa = MLDSA(params);

  final (pk, sk) = await dsa.keyGen();
  final msg = utf8.encode("message");
  final ctx = utf8.encode("context");

  final sig = await dsa.sign(sk, msg, ctx);

  return await dsa.verify(pk, msg, sig, ctx);
}

void main() {
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
      final result44 = await testRoundtrip(MLDSA44Parameters());
      setState(() {
        results['ML-DSA-44'] = result44;
      });

      final result65 = await testRoundtrip(MLDSA65Parameters());
      setState(() {
        results['ML-DSA-65'] = result65;
      });

      final result87 = await testRoundtrip(MLDSA87Parameters());
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
