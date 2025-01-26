

import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:ml_dsa/ml_dsa.dart';

class _SignRequest {
  final Uint8List sk;
  final Uint8List message;
  final Uint8List ctx;

  _SignRequest({
    required this.sk,
    required this.message,
    required this.ctx,
  });
}

class _VerifyRequest {
  final Uint8List pk;
  final Uint8List message;
  final Uint8List signature;
  final Uint8List ctx;

  _VerifyRequest({
    required this.pk,
    required this.message,
    required this.signature,
    required this.ctx,
  });
}

extension MLDSAAsync on MLDSA {
  (Uint8List, Uint8List) _keyGenCallback(dynamic _) {
    return keyGen();
  }

  (Uint8List, Uint8List) _keyGenWithSeedCallback(Uint8List rnd) {
    return keyGenWithSeed(rnd);
  }

  Uint8List _signCallback(_SignRequest request) {
    return sign(request.sk, request.message, request.ctx);
  }

  Uint8List _signDeterministicallyCallback(_SignRequest request) {
    return signDeterministically(request.sk, request.message, request.ctx);
  }

  bool _verifyCallback(_VerifyRequest request) {
    return verify(request.pk, request.message, request.signature, request.ctx);
  }

  Future<(Uint8List, Uint8List)> keyGenAsync() async {
    return await compute(_keyGenCallback, null);
  }

  Future<(Uint8List, Uint8List)> keyGenWithSeedAsync(Uint8List rnd) async {
    return await compute(_keyGenWithSeedCallback, rnd);
  }

  Future<Uint8List> signAsync(
      Uint8List sk, Uint8List message, Uint8List ctx) async {
    return await compute(
      _signCallback,
      _SignRequest(
        sk: sk,
        message: message,
        ctx: ctx,
      ),
    );
  }

  Future<Uint8List> signDeterministicallyAsync(
      Uint8List sk, Uint8List message, Uint8List ctx) async {
    return await compute(
      _signDeterministicallyCallback,
      _SignRequest(
        sk: sk,
        message: message,
        ctx: ctx,
      ),
    );
  }

  Future<bool> verifyAsync(
    Uint8List pk,
    Uint8List message,
    Uint8List signature,
    Uint8List ctx,
  ) async {
    return await compute(
      _verifyCallback,
      _VerifyRequest(
        pk: pk,
        message: message,
        signature: signature,
        ctx: ctx,
      ),
    );
  }
}