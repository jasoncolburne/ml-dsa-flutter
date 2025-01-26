# keccak

A modified version of the Keccak algorithm for use in ML-DSA.

Uses the optimized C reference implementation for 64-bit targets, and a pure dart
implementation for web (yes, this library is web compatible).

Async is not implemented with service workers for web.

The async routines also aren't even used in the ML-DSA implementation, but there
they are.

## testing

```
cd example
flutter run lib/main.dart
```

or

```
cd example
make service-worker
flutter run -d chrome lib/web.dart
```
