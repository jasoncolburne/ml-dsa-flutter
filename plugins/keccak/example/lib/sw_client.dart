import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:service_worker/window.dart' as sw;

class KeccakSWClient {
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

  static Future<int> create() async {
    final int requestId = _nextCreateRequest++;
    final Completer<int> completer = Completer<int>();
    _createRequests[requestId] = completer;

    serviceWorkerRegistration.active!.postMessage(json.encode({
      'id': requestId,
      'type': 'createRequest',
    }));

    return completer.future;
  }

  static Future<void> free(dynamic instance) async {
    final int requestId = _nextFreeRequest++;
    final Completer<void> completer = Completer<void>();
    _freeRequests[requestId] = completer;

    serviceWorkerRegistration.active!.postMessage(json.encode({
      'id': requestId,
      'type': 'freeRequest',
      'instance': instance,
    }));

    return completer.future;
  }

  static Future<void> initializeInstance(
    dynamic instance,
    int rate,
    int capacity,
    int hashBitLen,
    int delimitedSuffix,
  ) async {
    final int requestId = _nextInitializeRequest++;
    final Completer<void> completer = Completer<void>();
    _initializeRequests[requestId] = completer;

    serviceWorkerRegistration.active!.postMessage(json.encode({
      'id': requestId,
      'type': 'initializeRequest',
      'instance': instance,
      'rate': rate,
      'capacity': capacity,
      'hashBitLen': hashBitLen,
      'delimitedSuffix': delimitedSuffix,
    }));

    return completer.future;
  }

  static Future<void> absorb(dynamic instance, Uint8List message) async {
    final int requestId = _nextAbsorbRequest++;
    final Completer<void> completer = Completer<void>();
    _absorbRequests[requestId] = completer;

    serviceWorkerRegistration.active!.postMessage(json.encode({
      'id': requestId,
      'type': 'absorbRequest',
      'instance': instance,
      'message': base64.encode(message),
    }));

    return completer.future;
  }

  static Future<Uint8List> squeeze(dynamic instance, int bytesToSqueeze) async {
    final int requestId = _nextSqueezeRequest++;
    final Completer<Uint8List> completer = Completer<Uint8List>();
    _squeezeRequests[requestId] = completer;

    serviceWorkerRegistration.active!.postMessage(json.encode({
      'id': requestId,
      'type': 'squeezeRequest',
      'instance': instance,
      'bytesToSqueeze': bytesToSqueeze,
    }));

    return completer.future;
  }

  static Future<Uint8List> sha3_512(Uint8List message) async {
    final int requestId = _nextSHA3_512Request++;
    final Completer<Uint8List> completer = Completer<Uint8List>();
    _sha3_512Requests[requestId] = completer;

    serviceWorkerRegistration.active!.postMessage(json.encode({
      'id': requestId,
      'type': 'sha3512Request',
      'message': base64.encode(message),
    }));

    return completer.future;
  }
}

late sw.ServiceWorkerRegistration serviceWorkerRegistration;

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

void responseListener(sw.MessageEvent event) {
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
}
