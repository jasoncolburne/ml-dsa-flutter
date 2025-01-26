import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ml_dsa_example/sw_client.dart';

Future<bool> testRoundtrip(int strength) async {
  final (pk, sk) = await MLDSASWClient.keyGen(strength);
  final msg = utf8.encode("message");
  final ctx = utf8.encode("context");

  final sig = await MLDSASWClient.sign(strength, sk, msg, ctx);

  return await MLDSASWClient.verify(strength, pk, msg, sig, ctx);
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
