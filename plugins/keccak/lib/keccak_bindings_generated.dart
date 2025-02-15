// ignore_for_file: always_specify_types
// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

/// Bindings for `src/keccak.h`.
///
/// Regenerate bindings with `dart run ffigen --config ffigen.yaml`.
///
class KeccakBindings {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  KeccakBindings(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  KeccakBindings.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  /// Function to initialize the Keccak[r, c] sponge function instance used in sequential hashing mode.
  /// @param  hashInstance    Pointer to the hash instance to be initialized.
  /// @param  rate        The value of the rate r.
  /// @param  capacity    The value of the capacity c.
  /// @param  hashbitlen  The desired number of output bits,
  /// or 0 for an arbitrarily-long output.
  /// @param  delimitedSuffix Bits that will be automatically appended to the end
  /// of the input message, as in domain separation.
  /// This is a byte containing from 0 to 7 bits
  /// formatted like the @a delimitedData parameter of
  /// the Keccak_SpongeAbsorbLastFewBits() function.
  /// @pre    One must have r+c=1600 and the rate a multiple of 8 bits in this implementation.
  /// @return KECCAK_SUCCESS if successful, KECCAK_FAIL otherwise.
  HashReturn Keccak_HashInitialize(
    ffi.Pointer<Keccak_HashInstance> hashInstance,
    int rate,
    int capacity,
    int hashbitlen,
    int delimitedSuffix,
  ) {
    return HashReturn.fromValue(_Keccak_HashInitialize(
      hashInstance,
      rate,
      capacity,
      hashbitlen,
      delimitedSuffix,
    ));
  }

  late final _Keccak_HashInitializePtr = _lookup<
      ffi.NativeFunction<
          ffi.UnsignedInt Function(
              ffi.Pointer<Keccak_HashInstance>,
              ffi.UnsignedInt,
              ffi.UnsignedInt,
              ffi.UnsignedInt,
              ffi.UnsignedChar)>>('Keccak_HashInitialize');
  late final _Keccak_HashInitialize = _Keccak_HashInitializePtr.asFunction<
      int Function(ffi.Pointer<Keccak_HashInstance>, int, int, int, int)>();

  /// Function to give input data to be absorbed.
  /// @param  hashInstance    Pointer to the hash instance initialized by Keccak_HashInitialize().
  /// @param  data        Pointer to the input data.
  /// When @a databitLen is not a multiple of 8, the last bits of data must be
  /// in the least significant bits of the last byte (little-endian convention).
  /// In this case, the (8 - @a databitLen mod 8) most significant bits
  /// of the last byte are ignored.
  /// @param  databitLen  The number of input bits provided in the input data.
  /// @pre    In the previous call to Keccak_HashUpdate(), databitlen was a multiple of 8.
  /// @return KECCAK_SUCCESS if successful, KECCAK_FAIL otherwise.
  HashReturn Keccak_HashUpdate(
    ffi.Pointer<Keccak_HashInstance> hashInstance,
    ffi.Pointer<BitSequence> data,
    DartBitLength databitlen,
  ) {
    return HashReturn.fromValue(_Keccak_HashUpdate(
      hashInstance,
      data,
      databitlen,
    ));
  }

  late final _Keccak_HashUpdatePtr = _lookup<
      ffi.NativeFunction<
          ffi.UnsignedInt Function(ffi.Pointer<Keccak_HashInstance>,
              ffi.Pointer<BitSequence>, BitLength)>>('Keccak_HashUpdate');
  late final _Keccak_HashUpdate = _Keccak_HashUpdatePtr.asFunction<
      int Function(
          ffi.Pointer<Keccak_HashInstance>, ffi.Pointer<BitSequence>, int)>();

  /// Function to call after all input blocks have been input and to get
  /// output bits if the length was specified when calling Keccak_HashInitialize().
  /// @param  hashInstance    Pointer to the hash instance initialized by Keccak_HashInitialize().
  /// If @a hashbitlen was not 0 in the call to Keccak_HashInitialize(), the number of
  /// output bits is equal to @a hashbitlen.
  /// If @a hashbitlen was 0 in the call to Keccak_HashInitialize(), the output bits
  /// must be extracted using the Keccak_HashSqueeze() function.
  /// @param  hashval     Pointer to the buffer where to store the output data.
  /// @return KECCAK_SUCCESS if successful, KECCAK_FAIL otherwise.
  HashReturn Keccak_HashFinal(
    ffi.Pointer<Keccak_HashInstance> hashInstance,
    ffi.Pointer<BitSequence> hashval,
  ) {
    return HashReturn.fromValue(_Keccak_HashFinal(
      hashInstance,
      hashval,
    ));
  }

  late final _Keccak_HashFinalPtr = _lookup<
      ffi.NativeFunction<
          ffi.UnsignedInt Function(ffi.Pointer<Keccak_HashInstance>,
              ffi.Pointer<BitSequence>)>>('Keccak_HashFinal');
  late final _Keccak_HashFinal = _Keccak_HashFinalPtr.asFunction<
      int Function(
          ffi.Pointer<Keccak_HashInstance>, ffi.Pointer<BitSequence>)>();

  /// Function to squeeze output data.
  /// @param  hashInstance    Pointer to the hash instance initialized by Keccak_HashInitialize().
  /// @param  data        Pointer to the buffer where to store the output data.
  /// @param  databitlen  The number of output bits desired (must be a multiple of 8).
  /// @pre    Keccak_HashFinal() must have been already called.
  /// @pre    @a databitlen is a multiple of 8.
  /// @return KECCAK_SUCCESS if successful, KECCAK_FAIL otherwise.
  HashReturn Keccak_HashSqueeze(
    ffi.Pointer<Keccak_HashInstance> hashInstance,
    ffi.Pointer<BitSequence> data,
    DartBitLength databitlen,
  ) {
    return HashReturn.fromValue(_Keccak_HashSqueeze(
      hashInstance,
      data,
      databitlen,
    ));
  }

  late final _Keccak_HashSqueezePtr = _lookup<
      ffi.NativeFunction<
          ffi.UnsignedInt Function(ffi.Pointer<Keccak_HashInstance>,
              ffi.Pointer<BitSequence>, BitLength)>>('Keccak_HashSqueeze');
  late final _Keccak_HashSqueeze = _Keccak_HashSqueezePtr.asFunction<
      int Function(
          ffi.Pointer<Keccak_HashInstance>, ffi.Pointer<BitSequence>, int)>();

  /// Implementation of the SHAKE128 extendable output function (XOF) [FIPS 202].
  /// @param  output          Pointer to the output buffer.
  /// @param  outputByteLen   The desired number of output bytes.
  /// @param  input           Pointer to the input message.
  /// @param  inputByteLen    The length of the input message in bytes.
  /// @return 0 if successful, 1 otherwise.
  int SHAKE128(
    ffi.Pointer<ffi.UnsignedChar> output,
    int outputByteLen,
    ffi.Pointer<ffi.UnsignedChar> input,
    int inputByteLen,
  ) {
    return _SHAKE128(
      output,
      outputByteLen,
      input,
      inputByteLen,
    );
  }

  late final _SHAKE128Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<ffi.UnsignedChar>, ffi.Size,
              ffi.Pointer<ffi.UnsignedChar>, ffi.Size)>>('SHAKE128');
  late final _SHAKE128 = _SHAKE128Ptr.asFunction<
      int Function(ffi.Pointer<ffi.UnsignedChar>, int,
          ffi.Pointer<ffi.UnsignedChar>, int)>();

  /// Implementation of the SHAKE256 extendable output function (XOF) [FIPS 202].
  /// @param  output          Pointer to the output buffer.
  /// @param  outputByteLen   The desired number of output bytes.
  /// @param  input           Pointer to the input message.
  /// @param  inputByteLen    The length of the input message in bytes.
  /// @return 0 if successful, 1 otherwise.
  int SHAKE256(
    ffi.Pointer<ffi.UnsignedChar> output,
    int outputByteLen,
    ffi.Pointer<ffi.UnsignedChar> input,
    int inputByteLen,
  ) {
    return _SHAKE256(
      output,
      outputByteLen,
      input,
      inputByteLen,
    );
  }

  late final _SHAKE256Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<ffi.UnsignedChar>, ffi.Size,
              ffi.Pointer<ffi.UnsignedChar>, ffi.Size)>>('SHAKE256');
  late final _SHAKE256 = _SHAKE256Ptr.asFunction<
      int Function(ffi.Pointer<ffi.UnsignedChar>, int,
          ffi.Pointer<ffi.UnsignedChar>, int)>();

  /// Implementation of SHA3-224 [FIPS 202].
  /// @param  output          Pointer to the output buffer (28 bytes).
  /// @param  input           Pointer to the input message.
  /// @param  inputByteLen    The length of the input message in bytes.
  /// @return 0 if successful, 1 otherwise.
  int SHA3_224(
    ffi.Pointer<ffi.UnsignedChar> output,
    ffi.Pointer<ffi.UnsignedChar> input,
    int inputByteLen,
  ) {
    return _SHA3_224(
      output,
      input,
      inputByteLen,
    );
  }

  late final _SHA3_224Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<ffi.UnsignedChar>,
              ffi.Pointer<ffi.UnsignedChar>, ffi.Size)>>('SHA3_224');
  late final _SHA3_224 = _SHA3_224Ptr.asFunction<
      int Function(
          ffi.Pointer<ffi.UnsignedChar>, ffi.Pointer<ffi.UnsignedChar>, int)>();

  /// Implementation of SHA3-256 [FIPS 202].
  /// @param  output          Pointer to the output buffer (32 bytes).
  /// @param  input           Pointer to the input message.
  /// @param  inputByteLen    The length of the input message in bytes.
  /// @return 0 if successful, 1 otherwise.
  int SHA3_256(
    ffi.Pointer<ffi.UnsignedChar> output,
    ffi.Pointer<ffi.UnsignedChar> input,
    int inputByteLen,
  ) {
    return _SHA3_256(
      output,
      input,
      inputByteLen,
    );
  }

  late final _SHA3_256Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<ffi.UnsignedChar>,
              ffi.Pointer<ffi.UnsignedChar>, ffi.Size)>>('SHA3_256');
  late final _SHA3_256 = _SHA3_256Ptr.asFunction<
      int Function(
          ffi.Pointer<ffi.UnsignedChar>, ffi.Pointer<ffi.UnsignedChar>, int)>();

  /// Implementation of SHA3-384 [FIPS 202].
  /// @param  output          Pointer to the output buffer (48 bytes).
  /// @param  input           Pointer to the input message.
  /// @param  inputByteLen    The length of the input message in bytes.
  /// @return 0 if successful, 1 otherwise.
  int SHA3_384(
    ffi.Pointer<ffi.UnsignedChar> output,
    ffi.Pointer<ffi.UnsignedChar> input,
    int inputByteLen,
  ) {
    return _SHA3_384(
      output,
      input,
      inputByteLen,
    );
  }

  late final _SHA3_384Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<ffi.UnsignedChar>,
              ffi.Pointer<ffi.UnsignedChar>, ffi.Size)>>('SHA3_384');
  late final _SHA3_384 = _SHA3_384Ptr.asFunction<
      int Function(
          ffi.Pointer<ffi.UnsignedChar>, ffi.Pointer<ffi.UnsignedChar>, int)>();

  /// Implementation of SHA3-512 [FIPS 202].
  /// @param  output          Pointer to the output buffer (64 bytes).
  /// @param  input           Pointer to the input message.
  /// @param  inputByteLen    The length of the input message in bytes.
  /// @return 0 if successful, 1 otherwise.
  int SHA3_512(
    ffi.Pointer<ffi.UnsignedChar> output,
    ffi.Pointer<ffi.UnsignedChar> input,
    int inputByteLen,
  ) {
    return _SHA3_512(
      output,
      input,
      inputByteLen,
    );
  }

  late final _SHA3_512Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<ffi.UnsignedChar>,
              ffi.Pointer<ffi.UnsignedChar>, ffi.Size)>>('SHA3_512');
  late final _SHA3_512 = _SHA3_512Ptr.asFunction<
      int Function(
          ffi.Pointer<ffi.UnsignedChar>, ffi.Pointer<ffi.UnsignedChar>, int)>();
}

enum HashReturn {
  KECCAK_SUCCESS(0),
  KECCAK_FAIL(1),
  KECCAK_BAD_HASHLEN(2);

  final int value;
  const HashReturn(this.value);

  static HashReturn fromValue(int value) => switch (value) {
        0 => KECCAK_SUCCESS,
        1 => KECCAK_FAIL,
        2 => KECCAK_BAD_HASHLEN,
        _ => throw ArgumentError("Unknown value for HashReturn: $value"),
      };
}

final class Keccak_HashInstance extends ffi.Struct {
  external KeccakWidth1600_SpongeInstance sponge;

  @ffi.UnsignedInt()
  external int fixedOutputLength;

  @ffi.UnsignedChar()
  external int delimitedSuffix;
}

typedef KeccakWidth1600_SpongeInstance = KeccakWidth1600_SpongeInstanceStruct;

final class KeccakWidth1600_SpongeInstanceStruct extends ffi.Struct {
  external KeccakP1600_state state;

  @ffi.UnsignedInt()
  external int rate;

  @ffi.UnsignedInt()
  external int byteIOIndex;

  @ffi.Int()
  external int squeezing;
}

typedef KeccakP1600_state = KeccakP1600_plain64_state;

final class KeccakP1600_plain64_state extends ffi.Struct {
  @ffi.Array.multi([25])
  external ffi.Array<ffi.Uint64> A;
}

typedef BitSequence = ffi.Uint8;
typedef DartBitSequence = int;
typedef BitLength = ffi.Size;
typedef DartBitLength = int;
