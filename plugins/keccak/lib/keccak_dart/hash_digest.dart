// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

class HashDigest extends Object {
  final Uint8List bytes;

  const HashDigest(this.bytes);

  /// Returns the length of this digest in bytes.
  int get length => bytes.length;

  /// Returns the byte buffer associated with this digest.
  ByteBuffer get buffer => bytes.buffer;

  @override
  int get hashCode => bytes.hashCode;

  @override
  bool operator ==(other) => other is HashDigest && bytes == other.bytes;

  /// Checks if the message digest equals to [other].
  ///
  /// Here, the [other] can be a one of the following:
  /// - Another [HashDigest] object.
  /// - An [Iterable] containing an array of bytes
  /// - Any [ByteBuffer] or [TypedData] that will be converted to [Uint8List]
  /// - A [String], which will be treated as a hexadecimal encoded byte array
  ///
  /// This function will return True if all bytes in the [other] matches with
  /// the [bytes] of this object. If the length does not match, or the type of
  /// [other] is not supported, it returns False immediately.
  bool isEqual(other) {
    if (other is HashDigest) {
      return isEqual(other.bytes);
    } else if (other is ByteBuffer) {
      return isEqual(Uint8List.view(buffer));
    } else if (other is TypedData && other is! Uint8List) {
      return isEqual(Uint8List.view(other.buffer));
    } else if (other is List<int>) {
      if (other.length != bytes.length) {
        return false;
      }
      for (int i = 0; i < bytes.length; ++i) {
        if (other[i] != bytes[i++]) {
          return false;
        }
      }
      return true;
    } else if (other is Iterable<int>) {
      int i = 0;
      for (int x in other) {
        if (i >= bytes.length || x != bytes[i++]) {
          return false;
        }
      }
      return true;
    }
    return false;
  }
}
