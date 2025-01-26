import 'dart:convert';

import 'package:ml_dsa/ml_dsa.dart';
import 'package:service_worker/worker.dart';

void main(List<String> args) {
  onMessage.listen((event) {
    late MLDSA dsa;
    final parsedData = json.decode(event.data);

    final strength = parsedData['strength'];

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

    if (strength == 44) {
      dsa = MLDSA(MLDSA44Parameters());
    } else if (strength == 65) {
      dsa = MLDSA(MLDSA65Parameters());
    } else if (strength == 87) {
      dsa = MLDSA(MLDSA87Parameters());
    } else {
      throw Exception('unrecognized parameter set');
    }

    handle('keyGen', () {
      final (pk, sk) = dsa.keyGen();

      respond(event.source, 'keyGen', {
        'pk': base64.encode(pk),
        'sk': base64.encode(sk),
      });
    });

    handle('keyGenWithSeed', () {
      final (pk, sk) = dsa.keyGenWithSeed(base64.decode(parsedData['seed']));

      respond(event.source, 'keyGenWithSeed', {
        'pk': base64.encode(pk),
        'sk': base64.encode(sk),
      });
    });

    handle('sign', () {
      final sig = dsa.sign(
        base64.decode(parsedData['sk']),
        base64.decode(parsedData['message']),
        base64.decode(parsedData['ctx']),
      );

      respond(event.source, 'sign', {
        'sig': base64.encode(sig),
      });
    });

    handle('signDeterministically', () {
      final sig = dsa.signDeterministically(
        base64.decode(parsedData['sk']),
        base64.decode(parsedData['message']),
        base64.decode(parsedData['ctx']),
      );

      respond(event.source, 'signDeterministically', {
        'sig': base64.encode(sig),
      });
    });

    handle('verify', () {
      final valid = dsa.verify(
        base64.decode(parsedData['pk']),
        base64.decode(parsedData['message']),
        base64.decode(parsedData['sig']),
        base64.decode(parsedData['ctx']),
      );

      respond(event.source, 'verify', {'valid': valid});
    });
  });
}
