# ml_dsa

Module-Lattice-Based Digital Signature Standard

First, I created https://github.com/jasoncolburne/ml-dsa-go.
Then, I ported to dart in https://github.com/jasoncolburne/ml-dsa-dart.

Only tested for macOS, iOS, Android and Web.

I took implementations of Keccak from hashlib (for web/32-bit) and the
reference in C (for 64-bit). I needed to modify them slightly to permit
some of the squeezing operations.

## testing

`flutter test` doesn't build the keccak library. One can run all the tests with
`flutter run` for now.


### Known Answer Tests

```
cd example
flutter run integration_test/integration_test.dart
```

or, for web:

```
cd example
flutter run -d chrome integration_test/integration_test.dart
```

### Round-Trip Tests

```
cd example
flutter run test/ml_dsa_test.dart
```

or, for web:

```
cd example
flutter run -d chrome test/ml_dsa_test.dart
```

### Interactive app

A test app is also available,

```
cd example
flutter run lib/main.dart
```

or 

```
cd example
flutter run -d chrome lib/main.dart
```
