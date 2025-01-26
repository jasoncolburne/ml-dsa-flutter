import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:service_worker/window.dart' as sw;

import 'package:keccak/keccak.dart' as keccak;
import 'package:service_worker/worker.dart';

class Wrapper {
  static Future<dynamic> create() async {
    if (sw.isSupported) {
      if (serviceWorkerRegistration.active == null) {
        throw Exception('service worker not working');        
      }

      final int requestId = _nextCreateRequest++;
      final Completer<int> completer = Completer<int>();
      _createRequests[requestId] = completer;
      
      serviceWorkerRegistration.active?.postMessage(json.encode({
        'id': requestId,
        'type': 'createRequest',
      }));

      return completer.future;
    } else {
      return keccak.create();
    }
  }

  static Future<void> free(dynamic instance) async {
    if (sw.isSupported) {
      if (serviceWorkerRegistration.active == null) {
        throw Exception('service worker not working');        
      }

      final int requestId = _nextFreeRequest++;
      final Completer<void> completer = Completer<void>();
      _freeRequests[requestId] = completer;
      
      serviceWorkerRegistration.active?.postMessage(json.encode({
        'id': requestId,
        'type': 'freeRequest',
        'instance': instance,
      }));

      return completer.future;
    } else {
      return keccak.free(instance);
    }
  }

  static Future<void> initialize(
    dynamic instance,
    int rate,
    int capacity,
    int hashBitLen,
    int delimitedSuffix,
  ) async {
    if (sw.isSupported) {
      if (serviceWorkerRegistration.active == null) {
        throw Exception('service worker not working');        
      }

      final int requestId = _nextInitializeRequest++;
      final Completer<void> completer = Completer<void>();
      _initializeRequests[requestId] = completer;
      
      serviceWorkerRegistration.active?.postMessage(json.encode({
        'id': requestId,
        'type': 'initializeRequest',
        'instance': instance,
        'rate': rate,
        'capacity': capacity,
        'hashBitLen': hashBitLen,
        'delimitedSuffix': delimitedSuffix,
      }));

      return completer.future;
    } else {
      return keccak.initialize(instance, rate, capacity, hashBitLen, delimitedSuffix);
    }
  }

  static Future<void> absorb(dynamic instance, Uint8List message) async {
    if (sw.isSupported) {
      if (serviceWorkerRegistration.active == null) {
        throw Exception('service worker not working');        
      }

      final int requestId = _nextAbsorbRequest++;
      final Completer<void> completer = Completer<void>();
      _absorbRequests[requestId] = completer;
      
      serviceWorkerRegistration.active?.postMessage(json.encode({
        'id': requestId,
        'type': 'absorbRequest',
        'instance': instance,
        'message': base64.encode(message),
      }));

      return completer.future;
    } else {
      return keccak.absorbAsync(instance, message);
    }
  }

  static Future<Uint8List> squeeze(dynamic instance, int bytesToSqueeze) async {
    if (sw.isSupported) {
      if (serviceWorkerRegistration.active == null) {
        throw Exception('service worker not working');        
      }

      final int requestId = _nextSqueezeRequest++;
      final Completer<Uint8List> completer = Completer<Uint8List>();
      _squeezeRequests[requestId] = completer;
      
      serviceWorkerRegistration.active?.postMessage(json.encode({
        'id': requestId,
        'type': 'squeezeRequest',
        'instance': instance,
        'bytesToSqueeze': bytesToSqueeze,
      }));

      return completer.future;
    } else {
      return keccak.squeezeAsync(instance, bytesToSqueeze);
    }
  }

  static Future<Uint8List> sha3_512(Uint8List message) async {
    if (sw.isSupported) {
      if (serviceWorkerRegistration.active == null) {
        throw Exception('service worker not working');        
      }

      final int requestId = _nextSHA3_512Request++;
      final Completer<Uint8List> completer = Completer<Uint8List>();
      _sha3_512Requests[requestId] = completer;
      
      serviceWorkerRegistration.active?.postMessage(json.encode({
        'id': requestId,
        'type': 'sha3512Request',
        'message': base64.encode(message),
      }));

      return completer.future;
    } else {
      return keccak.sha3_512Async(message);
    }
  }
}

late ServiceWorkerRegistration serviceWorkerRegistration;

int _nextCreateRequest = 0;
int _nextFreeRequest = 0;
int _nextInitializeRequest = 0;
int _nextAbsorbRequest = 0;
int _nextSqueezeRequest = 0;
int _nextSHA3_512Request = 0;

final Map<int, Completer<int>> _createRequests = <int, Completer<int>>{};
final Map<int, Completer<void>> _freeRequests = <int, Completer<void>>{};
final Map<int, Completer<void>> _initializeRequests = <int, Completer<void>>{};
final Map<int, Completer<void>> _absorbRequests = <int, Completer<void>>{};
final Map<int, Completer<Uint8List>> _squeezeRequests =
    <int, Completer<Uint8List>>{};
final Map<int, Completer<Uint8List>> _sha3_512Requests =
    <int, Completer<Uint8List>>{};


void main() async {
  if (sw.isSupported) {
    serviceWorkerRegistration = await sw.register('sw.dart.js');
    if (serviceWorkerRegistration.installing != null) {
      await Future.delayed(Duration(milliseconds: 200));
    }

    sw.onMessage.listen((event) {
      final parsedData = json.decode(event.data);

      if (parsedData['type'] == 'createResponse') {
        final Completer<int> completer = _createRequests[parsedData['id']]!;
        _createRequests.remove(parsedData['id']);
        completer.complete(parsedData['instance']);
        return;
      }

      if (parsedData['type'] == 'freeResponse') {
        final Completer<void> completer = _freeRequests[parsedData['id']]!;
        _freeRequests.remove(parsedData['id']);
        completer.complete();
        return;
      }

      if (parsedData['type'] == 'initializeResponse') {
        final Completer<void> completer = _initializeRequests[parsedData['id']]!;
        _initializeRequests.remove(parsedData['id']);
        completer.complete();
        return;
      }

      if (parsedData['type'] == 'absorbResponse') {
        final Completer<void> completer = _absorbRequests[parsedData['id']]!;
        _absorbRequests.remove(parsedData['id']);
        completer.complete();
        return;
      }

      if (parsedData['type'] == 'squeezeResponse') {
        final Completer<Uint8List> completer = _squeezeRequests[parsedData['id']]!;
        _squeezeRequests.remove(parsedData['id']);
        completer.complete(base64.decode(parsedData['bytes']));
        return;
      }

      if (parsedData['type'] == 'sha3512Response') {
        final Completer<Uint8List> completer = _sha3_512Requests[parsedData['id']]!;
        _sha3_512Requests.remove(parsedData['id']);
        completer.complete(base64.decode(parsedData['bytes']));
        return;
      }
    });
  }

  runApp(MyApp(
    squeezeAsyncResult: squeezeExample(),
    sha3AsyncResult: sha3Example(),
  ));
}

Future<Uint8List> squeezeExample() async {
  final shake256 = await Wrapper.create();

  await Wrapper.initialize(shake256, 1088, 512, 0, 0x1f);
  await Wrapper.absorb(shake256, utf8.encode("some data"));

  for (int i = 0; i < 10000; i++) {
    await Wrapper.squeeze(shake256, 3);
  }

  final output = await Wrapper.squeeze(shake256, 13);
  await Wrapper.free(shake256);

  return output;
}

Future<Uint8List> sha3Example() async {
  final digest = await Wrapper.sha3_512(utf8.encode("some data"));

  return digest;
}

class MyApp extends StatefulWidget {
  final Future<Uint8List> squeezeAsyncResult;
  final Future<Uint8List> sha3AsyncResult;

  const MyApp({super.key, required this.squeezeAsyncResult, required this.sha3AsyncResult,});

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
    const description = 'This calls a web implementation using 32-bit operations '
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
