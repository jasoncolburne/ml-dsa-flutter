
// ignore_for_file: camel_case_types

import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart' as ffi;

import 'keccak_bindings_generated.dart';

typedef HashPointer = Pointer<Keccak_HashInstance>;
typedef KeccakInstance = HashPointer;

// stateSize and paddingByte are ignored here and set during initialize
HashPointer create({int stateSize = 256 >> 3, int paddingByte = 0x1f}) {
  final Pointer<Keccak_HashInstance> instance = ffi.calloc<Keccak_HashInstance>(sizeOf<Keccak_HashInstance>());
  return instance;
}

void free(
  HashPointer instance,
) {
  ffi.calloc.free(instance);
}

void initialize(
  HashPointer instance,
  int rate,
  int capacity,
  int hashBitLen,
  int delimitedSuffix,
) {
  final HashReturn result = _bindings.Keccak_HashInitialize(instance, rate, capacity, hashBitLen, delimitedSuffix);
  if (result != HashReturn.KECCAK_SUCCESS) {
    throw Exception('failed to initialize');
  }
}

void absorb(
  HashPointer instance,
  Uint8List data,
) {
  final length = data.length;
  final Pointer<Uint8> buffer = ffi.calloc<Uint8>(length);
  final Uint8List typedList = buffer.asTypedList(length);
  typedList.setAll(0, data);

  final HashReturn result = _bindings.Keccak_HashUpdate(instance, buffer, length * 8);
  ffi.calloc.free(buffer);
  if (result != HashReturn.KECCAK_SUCCESS) {
    throw Exception('failed to absorb');
  }
}

Uint8List squeeze(
  HashPointer instance,
  int bytesToSqueeze,
) {
  final Pointer<Uint8> buffer = ffi.calloc<Uint8>(bytesToSqueeze);

  final HashReturn result = _bindings.Keccak_HashSqueeze(instance, buffer, bytesToSqueeze * 8);

  final Uint8List output = Uint8List.fromList(buffer.asTypedList(bytesToSqueeze));
  ffi.calloc.free(buffer);

  if (result != HashReturn.KECCAK_SUCCESS) {
    throw Exception('failed to squeeze');
  }

  return output;
}

Uint8List sha3_512(Uint8List data) {
  final length = data.length;
  
  final Pointer<Uint8> inputBuffer = ffi.calloc<Uint8>(length);
  final Uint8List typedList = inputBuffer.asTypedList(length);
  typedList.setAll(0, data);

  final Pointer<Uint8> outputBuffer = ffi.calloc<Uint8>(64);

  final result = _bindings.SHA3_512(outputBuffer as Pointer<UnsignedChar>, inputBuffer as Pointer<UnsignedChar>, length);

  final Uint8List output = Uint8List.fromList(outputBuffer.asTypedList(64));
  ffi.calloc.free(inputBuffer);
  ffi.calloc.free(outputBuffer);

  if (result != 0) {
    throw Exception("failed to create sha3-512 digest");
  }

  return output;
}

Future<void> absorbAsync(
  HashPointer instance,
  Uint8List data,
) async {
  final SendPort helperIsolateSendPort = await _helperIsolateSendPort;
  final int requestId = _nextAbsorbRequest++;
  final _AbsorbRequest request = _AbsorbRequest(requestId, instance, data);
  final Completer<void> completer = Completer<void>();
  _absorbRequests[requestId] = completer;
  helperIsolateSendPort.send(request);
  return completer.future;
}

Future<Uint8List> squeezeAsync(
  HashPointer instance,
  int bytesToSqueeze
) async {
  final SendPort helperIsolateSendPort = await _helperIsolateSendPort;
  final int requestId = _nextSqueezeRequest++;
  final _SqueezeRequest request = _SqueezeRequest(requestId, instance, bytesToSqueeze);
  final Completer<Uint8List> completer = Completer<Uint8List>();
  _squeezeRequests[requestId] = completer;
  helperIsolateSendPort.send(request);
  return completer.future;
}

Future<Uint8List> sha3_512Async(
  Uint8List data
) async {
  final SendPort helperIsolateSendPort = await _helperIsolateSendPort;
  final int requestId = _nextSHA3_512Request++;
  final _SHA3_512Request request = _SHA3_512Request(requestId, data);
  final Completer<Uint8List> completer = Completer<Uint8List>();
  _sha3_512Requests[requestId] = completer;
  helperIsolateSendPort.send(request);
  return completer.future;
}

const String _libName = 'keccak';

/// The dynamic library in which the symbols for [MlDsaIoBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final KeccakBindings _bindings = KeccakBindings(_dylib);

class _AbsorbRequest {
  final int id;

  final HashPointer instance;
  final Uint8List data;

  const _AbsorbRequest(this.id, this.instance, this.data);
}

class _AbsorbResponse {
  final int id;

  const _AbsorbResponse(this.id);
}

class _SqueezeRequest {
  final int id;

  final HashPointer instance;
  final int bytesToSqueeze;

  const _SqueezeRequest(this.id, this.instance, this.bytesToSqueeze);
}

class _SqueezeResponse {
  final int id;

  final Uint8List bytes;

  const _SqueezeResponse(this.id, this.bytes);
}

class _SHA3_512Request {
  final int id;

  final Uint8List data;

  const _SHA3_512Request(this.id, this.data);
}

class _SHA3_512Response {
  final int id;

  final Uint8List bytes;

  const _SHA3_512Response(this.id, this.bytes);
}


/// Counters
int _nextAbsorbRequest = 0;
int _nextSqueezeRequest = 0;
int _nextSHA3_512Request = 0;

/// Mappings
final Map<int, Completer<void>> _absorbRequests = <int, Completer<void>>{};
final Map<int, Completer<Uint8List>> _squeezeRequests = <int, Completer<Uint8List>>{};
final Map<int, Completer<Uint8List>> _sha3_512Requests = <int, Completer<Uint8List>>{};


/// The SendPort belonging to the helper isolate.
Future<SendPort> _helperIsolateSendPort = () async {
  // The helper isolate is going to send us back a SendPort, which we want to
  // wait for.
  final Completer<SendPort> completer = Completer<SendPort>();

  // Receive port on the main isolate to receive messages from the helper.
  // We receive two types of messages:
  // 1. A port to send messages on.
  // 2. Responses to requests we sent.
  final ReceivePort receivePort = ReceivePort()
    ..listen((dynamic data) {
      if (data is SendPort) {
        completer.complete(data);
        return;
      }

      if (data is _AbsorbResponse) {
        final Completer<void> completer = _absorbRequests[data.id]!;
        _absorbRequests.remove(data.id);
        completer.complete();
        return;
      }

      if (data is _SqueezeResponse) {
        final Completer<Uint8List> completer = _squeezeRequests[data.id]!;
        _squeezeRequests.remove(data.id);
        completer.complete(data.bytes);
        return;
      }

      if (data is _SHA3_512Response) {
        final Completer<Uint8List> completer = _sha3_512Requests[data.id]!;
        _sha3_512Requests.remove(data.id);
        completer.complete(data.bytes);
        return;
      }

      throw UnsupportedError('Unsupported message type: ${data.runtimeType}');
    });

  // Start the helper isolate.
  await Isolate.spawn((SendPort sendPort) async {
    final ReceivePort helperReceivePort = ReceivePort()
      ..listen((dynamic data) {

        if (data is _AbsorbRequest) {
          absorb(data.instance, data.data);
          final _AbsorbResponse response = _AbsorbResponse(data.id);
          sendPort.send(response);
          return;
        }

        if (data is _SqueezeRequest) {
          final output = squeeze(data.instance, data.bytesToSqueeze);
          final _SqueezeResponse response = _SqueezeResponse(data.id, output);
          sendPort.send(response);
          return;
        }

        if (data is _SHA3_512Request) {
          final Uint8List output = sha3_512(data.data);
          final _SHA3_512Response response = _SHA3_512Response(data.id, output);
          sendPort.send(response);
          return;
        }

        throw UnsupportedError('Unsupported message type: ${data.runtimeType}');
      });

    // Send the port to the main isolate on which we can receive requests.
    sendPort.send(helperReceivePort.sendPort);
  }, receivePort.sendPort);

  // Wait until the helper isolate has sent us back the SendPort on which we
  // can start sending requests.
  return completer.future;
}();
