import 'dart:convert';
import 'dart:typed_data';

import 'package:service_worker/worker.dart';
import 'package:keccak/keccak.dart' as keccak;

int _nextKeccakInstance = 0;
final Map<int, keccak.KeccakInstance> _keccakInstances =
    <int, keccak.KeccakInstance>{};

void main(List<String> args) {
  onMessage.listen((event) {
    final parsedData = json.decode(event.data);

    void handle(String type, Function() handler) {
      if (parsedData['type'] == '${type}Request') {
        handler();
      }
    }

    void respond(
        ServiceWorkerClient source, String type, Map<String, dynamic> data) {
      data['type'] = '${type}Response';
      data['id'] = parsedData['id'];
      source.postMessage(json.encode(data));
    }

    handle('create', () {
      final instance = keccak.create();
      final instanceId = _nextKeccakInstance++;

      _keccakInstances[instanceId] = instance;

      respond(event.source, 'create', {'instance': instanceId});
    });

    handle('free', () {
      final instance = _keccakInstances[parsedData['instance']]!;
      keccak.free(instance);
      _keccakInstances.remove(parsedData['instance']);

      respond(event.source, 'free', {});
    });

    handle('initialize', () {
      final instance = _keccakInstances[parsedData['instance']]!;
      keccak.initialize(
        instance,
        parsedData['rate'],
        parsedData['capacity'],
        parsedData['hashBitLen'],
        parsedData['delimitedSuffix'],
      );

      respond(event.source, 'initialize', {});
    });

    handle('absorb', () {
      final instance = _keccakInstances[parsedData['instance']]!;
      keccak.absorb(
        instance,
        Uint8List.fromList(base64.decode(parsedData['message'])),
      );

      respond(event.source, 'absorb', {});
    });

    handle('squeeze', () {
      final instance = _keccakInstances[parsedData['instance']]!;
      final bytes = keccak.squeeze(
        instance,
        parsedData['bytesToSqueeze'],
      );

      respond(event.source, 'squeeze', {'bytes': base64.encode(bytes)});
    });

    handle('sha3512', () {
      final bytes = keccak.sha3_512(
        Uint8List.fromList(base64.decode(parsedData['message'])),
      );

      respond(event.source, 'sha3512', {'bytes': base64.encode(bytes)});
    });
  });
}
