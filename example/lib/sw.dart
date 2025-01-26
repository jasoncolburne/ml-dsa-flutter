import 'dart:convert';

import 'package:ml_dsa/ml_dsa.dart';
import 'package:service_worker/worker.dart';

void main(List<String> args) {
  onMessage.listen((event) {
    late MLDSA dsa;
    final parsedData = json.decode(event.data);

    final strength = parsedData['strength'];

    if (strength == 44) {
      dsa = MLDSA(MLDSA44Parameters());
    } else if (strength == 65) {
      dsa = MLDSA(MLDSA65Parameters());
    } else if (strength == 87) {
      dsa = MLDSA(MLDSA87Parameters());
    } else {
      throw Exception('unrecognized parameter set');
    }

    if (parsedData['type'] == 'keyGenRequest') {
      final (pk, sk) = dsa.keyGen();

      final data = {
        'id': parsedData['id'],
        'type': 'keyGenResponse',
        'pk': base64.encode(pk),
        'sk': base64.encode(sk),
      };
      event.source.postMessage(json.encode(data));
    }

    if (parsedData['type'] == 'keyGenWithSeedRequest') {
      final (pk, sk) = dsa.keyGenWithSeed(base64.decode(parsedData['seed']));

      final data = {
        'id': parsedData['id'],
        'type': 'keyGenWithSeedResponse',
        'pk': base64.encode(pk),
        'sk': base64.encode(sk),
      };
      event.source.postMessage(json.encode(data));
    }

    if (parsedData['type'] == 'signRequest') {
      final sig = dsa.sign(
        base64.decode(parsedData['sk']),
        base64.decode(parsedData['message']),
        base64.decode(parsedData['ctx']),
      );

      final data = {
        'id': parsedData['id'],
        'type': 'signResponse',
        'sig': base64.encode(sig),
      };
      event.source.postMessage(json.encode(data));
    }

    if (parsedData['type'] == 'signDeterministicallyRequest') {
      final sig = dsa.signDeterministically(
        base64.decode(parsedData['sk']),
        base64.decode(parsedData['message']),
        base64.decode(parsedData['ctx']),
      );

      final data = {
        'id': parsedData['id'],
        'type': 'signDeterministicallyResponse',
        'sig': base64.encode(sig),
      };
      event.source.postMessage(json.encode(data));
    }

    if (parsedData['type'] == 'verifyRequest') {
      final valid = dsa.verify(
        base64.decode(parsedData['pk']),
        base64.decode(parsedData['message']),
        base64.decode(parsedData['sig']),
        base64.decode(parsedData['ctx']),
      );

      final data = {
        'id': parsedData['id'],
        'type': 'verifyResponse',
        'valid': valid
      };
      event.source.postMessage(json.encode(data));
    }
  });
}
