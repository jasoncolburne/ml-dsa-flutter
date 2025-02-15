import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:service_worker/window.dart' as sw;

void request(sw.ServiceWorker worker, int id, int strength, String type,
    Map<String, dynamic> data) {
  data['id'] = id;
  data['strength'] = strength;
  data['type'] = '${type}Request';
  worker.postMessage(json.encode(data));
}

class MLDSASWClient {
  static Future<void> initialize() async {
    if (sw.isSupported) {
      serviceWorkerRegistration = await sw.register('sw.dart.js');

      if (serviceWorkerRegistration.installing != null) {
        await Future.delayed(Duration(milliseconds: 200));
      }

      sw.onMessage.listen(responseListener);
    } else {
      throw Exception('service worker not supported');
    }
  }

  static Future<(Uint8List, Uint8List)> keyGen(int strength) async {
    final int requestId = _nextKeyGenRequest++;
    final Completer<(Uint8List, Uint8List)> completer =
        Completer<(Uint8List, Uint8List)>();
    _keyGenRequests[requestId] = completer;

    request(
        serviceWorkerRegistration.active!, requestId, strength, 'keyGen', {});

    return completer.future;
  }

  static Future<(Uint8List, Uint8List)> keyGenWithSeed(
      int strength, Uint8List seed) async {
    final int requestId = _nextKeyGenWithSeedRequest++;
    final Completer<(Uint8List, Uint8List)> completer =
        Completer<(Uint8List, Uint8List)>();
    _keyGenWithSeedRequests[requestId] = completer;

    request(serviceWorkerRegistration.active!, requestId, strength,
        'keyGenWithSeed', {
      'seed': base64.encode(seed),
    });

    return completer.future;
  }

  static Future<Uint8List> sign(
      int strength, Uint8List sk, Uint8List message, Uint8List ctx) async {
    final int requestId = _nextSignRequest++;
    final Completer<Uint8List> completer = Completer<Uint8List>();
    _signRequests[requestId] = completer;

    request(serviceWorkerRegistration.active!, requestId, strength, 'sign', {
      'sk': base64.encode(sk),
      'message': base64.encode(message),
      'ctx': base64.encode(ctx),
    });

    return completer.future;
  }

  static Future<Uint8List> signDeterministically(
      int strength, Uint8List sk, Uint8List message, Uint8List ctx) async {
    final int requestId = _nextSignDeterministicallyRequest++;
    final Completer<Uint8List> completer = Completer<Uint8List>();
    _signDeterministicallyRequests[requestId] = completer;

    request(serviceWorkerRegistration.active!, requestId, strength,
        'signDeterministically', {
      'sk': base64.encode(sk),
      'message': base64.encode(message),
      'ctx': base64.encode(ctx),
    });

    return completer.future;
  }

  static Future<bool> verify(int strength, Uint8List pk, Uint8List message,
      Uint8List sig, Uint8List ctx) async {
    final int requestId = _nextVerifyRequest++;
    final Completer<bool> completer = Completer<bool>();
    _verifyRequests[requestId] = completer;

    request(serviceWorkerRegistration.active!, requestId, strength, 'verify', {
      'pk': base64.encode(pk),
      'message': base64.encode(message),
      'sig': base64.encode(sig),
      'ctx': base64.encode(ctx),
    });

    return completer.future;
  }
}

late sw.ServiceWorkerRegistration serviceWorkerRegistration;

int _nextKeyGenRequest = 0;
int _nextKeyGenWithSeedRequest = 0;
int _nextSignRequest = 0;
int _nextSignDeterministicallyRequest = 0;
int _nextVerifyRequest = 0;

final Map<int, Completer<(Uint8List, Uint8List)>> _keyGenRequests =
    <int, Completer<(Uint8List, Uint8List)>>{};
final Map<int, Completer<(Uint8List, Uint8List)>> _keyGenWithSeedRequests =
    <int, Completer<(Uint8List, Uint8List)>>{};
final Map<int, Completer<Uint8List>> _signRequests =
    <int, Completer<Uint8List>>{};
final Map<int, Completer<Uint8List>> _signDeterministicallyRequests =
    <int, Completer<Uint8List>>{};
final Map<int, Completer<bool>> _verifyRequests = <int, Completer<bool>>{};

void responseListener(sw.MessageEvent event) {
  final parsedData = json.decode(event.data);

  void handle(String type, Function() handler) {
    if (parsedData['type'] == '${type}Response') {
      handler();
    }
  }

  handle('keyGen', () {
    final Completer<(Uint8List, Uint8List)> completer =
        _keyGenRequests[parsedData['id']]!;
    _keyGenRequests.remove(parsedData['id']);
    completer.complete(
        (base64.decode(parsedData['pk']), base64.decode(parsedData['sk'])));
  });

  handle('keyGenWithSeed', () {
    final Completer<(Uint8List, Uint8List)> completer =
        _keyGenWithSeedRequests[parsedData['id']]!;
    _keyGenWithSeedRequests.remove(parsedData['id']);
    completer.complete(
        (base64.decode(parsedData['pk']), base64.decode(parsedData['sk'])));
  });

  handle('sign', () {
    final Completer<Uint8List> completer = _signRequests[parsedData['id']]!;
    _signRequests.remove(parsedData['id']);
    completer.complete(base64.decode(parsedData['sig']));
  });

  handle('signDeterministically', () {
    final Completer<Uint8List> completer =
        _signDeterministicallyRequests[parsedData['id']]!;
    _signDeterministicallyRequests.remove(parsedData['id']);
    completer.complete(base64.decode(parsedData['sig']));
  });

  handle('verify', () {
    final Completer<bool> completer = _verifyRequests[parsedData['id']]!;
    _verifyRequests.remove(parsedData['id']);
    completer.complete(parsedData['valid']);
  });
}
