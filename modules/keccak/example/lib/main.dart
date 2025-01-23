import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:keccak/keccak.dart' as keccak;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late int sumResult;
  late Future<Uint8List> squeezeAsyncResult;
  late Future<Uint8List> sha3AsyncResult;

  Future<Uint8List> squeezeExample() async {
    final shake256 = keccak.create();
    
    for (int i = 0; i < 10000; i++) {
      keccak.initialize(shake256, 1088, 512, 0, 0x1f);
      await keccak.absorbAsync(shake256, utf8.encode("some data"));
      await keccak.squeezeAsync(shake256, 3);
    }

    final output = await keccak.squeezeAsync(shake256, 13);
    keccak.free(shake256);

    return output;
  }

  Future<Uint8List> sha3Example() async {
    final digest = await keccak.sha3_512Async(utf8.encode("some data"));

    return digest;
  }

  @override
  void initState() {
    super.initState();
    squeezeAsyncResult = squeezeExample();
    sha3AsyncResult = sha3Example();
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Packages'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text(
                  'This calls a native function through FFI that is shipped as source in the package. '
                  'The native code is built as part of the Flutter Runner build.',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                FutureBuilder<Uint8List>(
                  future: squeezeAsyncResult,
                  builder: (BuildContext context, AsyncSnapshot<Uint8List> value) {
                    final displayValue =
                        (value.hasData) ? value.data : 'loading';
                    return Text(
                      'await squeeze() = $displayValue',
                      style: textStyle,
                      textAlign: TextAlign.center,
                    );
                  },
                ),
                spacerSmall,
                FutureBuilder<Uint8List>(
                  future: sha3AsyncResult,
                  builder: (BuildContext context, AsyncSnapshot<Uint8List> value) {
                    final displayValue =
                        (value.hasData) ? value.data : 'loading';
                    return Text(
                      'await sha3() = $displayValue',
                      style: textStyle,
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
