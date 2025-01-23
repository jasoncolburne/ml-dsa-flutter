# keccak

A modified version of the Keccak algorithm for use in ML-DSA.

Uses the C reference implementation for 64-bit targets, and a pure dart implementation for web (yes, this library is web compatible).

The async routines aren't even used in the ML-DSA implementation, but there the are.

## testing

```
cd example
flutter run lib/main.dart
```

or

```
cd example
flutter run -d chrome lib/main.dart
```
