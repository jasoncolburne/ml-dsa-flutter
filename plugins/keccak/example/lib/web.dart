import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'sw_client.dart';

void main() async {
  await KeccakSWClient.initialize();

  runApp(MyApp(
    squeezeAsyncResult: squeezeExample(),
    sha3AsyncResult: sha3Example(),
  ));
}

Future<Uint8List> squeezeExample() async {
  final shake256 = await KeccakSWClient.create();

  await KeccakSWClient.initializeInstance(shake256, 1088, 512, 0, 0x1f);
  await KeccakSWClient.absorb(shake256, utf8.encode("some data"));

  for (int i = 0; i < 10000; i++) {
    await KeccakSWClient.squeeze(shake256, 3);
  }

  final output = await KeccakSWClient.squeeze(shake256, 13);
  await KeccakSWClient.free(shake256);

  return output;
}

Future<Uint8List> sha3Example() async {
  final digest = await KeccakSWClient.sha3_512(utf8.encode("some data"));

  return digest;
}

class MyApp extends StatefulWidget {
  final Future<Uint8List> squeezeAsyncResult;
  final Future<Uint8List> sha3AsyncResult;

  const MyApp({
    super.key,
    required this.squeezeAsyncResult,
    required this.sha3AsyncResult,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);

    const title = 'Web Implementation';
    const description =
        'This calls a web implementation using 32-bit operations '
        'to emulate 64-bit ones.';

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(title),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text(
                  description,
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                FutureBuilder<Uint8List>(
                  future: widget.squeezeAsyncResult,
                  builder:
                      (BuildContext context, AsyncSnapshot<Uint8List> value) {
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
                  future: widget.sha3AsyncResult,
                  builder:
                      (BuildContext context, AsyncSnapshot<Uint8List> value) {
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
