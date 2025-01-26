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

    if (parsedData['type'] == 'createRequest') {
      final instance = keccak.create();
      final instanceId = _nextKeccakInstance++;

      _keccakInstances[instanceId] = instance;

      final data = {
        'id': parsedData['id'],
        'type': 'createResponse',
        'instance': instanceId
      };
      event.source.postMessage(json.encode(data));
    }

    if (parsedData['type'] == 'freeRequest') {
      final instance = _keccakInstances[parsedData['instance']]!;
      keccak.free(instance);
      _keccakInstances.remove(parsedData['instance']);

      final data = {'id': parsedData['id'], 'type': 'freeResponse'};
      event.source.postMessage(json.encode(data));
    }

    if (parsedData['type'] == 'initializeRequest') {
      final instance = _keccakInstances[parsedData['instance']]!;
      keccak.initialize(
        instance,
        parsedData['rate'],
        parsedData['capacity'],
        parsedData['hashBitLen'],
        parsedData['delimitedSuffix'],
      );

      final data = {'id': parsedData['id'], 'type': 'initializeResponse'};
      event.source.postMessage(json.encode(data));
    }

    if (parsedData['type'] == 'absorbRequest') {
      final instance = _keccakInstances[parsedData['instance']]!;
      keccak.absorb(
        instance,
        Uint8List.fromList(base64.decode(parsedData['message'])),
      );

      final data = {'id': parsedData['id'], 'type': 'absorbResponse'};
      event.source.postMessage(json.encode(data));
    }

    if (parsedData['type'] == 'squeezeRequest') {
      final instance = _keccakInstances[parsedData['instance']]!;
      final bytes = keccak.squeeze(
        instance,
        parsedData['bytesToSqueeze'],
      );

      final data = {
        'id': parsedData['id'],
        'type': 'squeezeResponse',
        'bytes': base64.encode(bytes)
      };
      event.source.postMessage(json.encode(data));
    }

    if (parsedData['type'] == 'sha3512Request') {
      final bytes = keccak.sha3_512(
        Uint8List.fromList(base64.decode(parsedData['message'])),
      );

      final data = {
        'id': parsedData['id'],
        'type': 'sha3512Response',
        'bytes': base64.encode(bytes)
      };
      event.source.postMessage(json.encode(data));
    }
  });
}
