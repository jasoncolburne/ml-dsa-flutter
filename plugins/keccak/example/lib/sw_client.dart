import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:service_worker/window.dart' as sw;

void request(
    sw.ServiceWorker worker, int id, String type, Map<String, dynamic> data) {
  data['id'] = id;
  data['type'] = '${type}Request';
  worker.postMessage(json.encode(data));
}

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

    request(serviceWorkerRegistration.active!, requestId, 'create', {});

    return completer.future;
  }

  static Future<void> free(dynamic instance) async {
    final int requestId = _nextFreeRequest++;
    final Completer<void> completer = Completer<void>();
    _freeRequests[requestId] = completer;

    request(serviceWorkerRegistration.active!, requestId, 'free', {
      'instance': instance,
    });

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

    request(serviceWorkerRegistration.active!, requestId, 'initialize', {
      'instance': instance,
      'rate': rate,
      'capacity': capacity,
      'hashBitLen': hashBitLen,
      'delimitedSuffix': delimitedSuffix,
    });

    return completer.future;
  }

  static Future<void> absorb(dynamic instance, Uint8List message) async {
    final int requestId = _nextAbsorbRequest++;
    final Completer<void> completer = Completer<void>();
    _absorbRequests[requestId] = completer;

    request(serviceWorkerRegistration.active!, requestId, 'absorb', {
      'instance': instance,
      'message': base64.encode(message),
    });

    return completer.future;
  }

  static Future<Uint8List> squeeze(dynamic instance, int bytesToSqueeze) async {
    final int requestId = _nextSqueezeRequest++;
    final Completer<Uint8List> completer = Completer<Uint8List>();
    _squeezeRequests[requestId] = completer;

    request(serviceWorkerRegistration.active!, requestId, 'squeeze', {
      'instance': instance,
      'bytesToSqueeze': bytesToSqueeze,
    });

    return completer.future;
  }

  static Future<Uint8List> sha3_512(Uint8List message) async {
    final int requestId = _nextSHA3_512Request++;
    final Completer<Uint8List> completer = Completer<Uint8List>();
    _sha3_512Requests[requestId] = completer;

    request(serviceWorkerRegistration.active!, requestId, 'sha3512', {
      'message': base64.encode(message),
    });

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

  void handle(String type, Function() handler) {
    if (parsedData['type'] == '${type}Response') {
      handler();
    }
  }

  handle('create', () {
    final Completer<int> completer = _createRequests[parsedData['id']]!;
    _createRequests.remove(parsedData['id']);
    completer.complete(parsedData['instance']);
  });

  handle('free', () {
    final Completer<void> completer = _freeRequests[parsedData['id']]!;
    _freeRequests.remove(parsedData['id']);
    completer.complete();
  });

  handle('initialize', () {
    final Completer<void> completer = _initializeRequests[parsedData['id']]!;
    _initializeRequests.remove(parsedData['id']);
    completer.complete();
  });

  handle('absorb', () {
    final Completer<void> completer = _absorbRequests[parsedData['id']]!;
    _absorbRequests.remove(parsedData['id']);
    completer.complete();
  });

  handle('squeeze', () {
    final Completer<Uint8List> completer = _squeezeRequests[parsedData['id']]!;
    _squeezeRequests.remove(parsedData['id']);
    completer.complete(base64.decode(parsedData['bytes']));
  });

  handle('sha3512', () {
    final Completer<Uint8List> completer = _sha3_512Requests[parsedData['id']]!;
    _sha3_512Requests.remove(parsedData['id']);
    completer.complete(base64.decode(parsedData['bytes']));
  });
}
