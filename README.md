# ml_dsa

Module-Lattice-Based Digital Signature Standard

First, I created https://github.com/jasoncolburne/ml-dsa-go.
Then, I ported to dart in https://github.com/jasoncolburne/ml-dsa-dart.

Only tested for macOS, iOS, Android and Web.

I took implementations of Keccak from hashlib (for web/32-bit) and the
optimized reference in C (for 64-bit). I needed to modify them slightly to permit
some of the squeezing operations.

## Testing

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
make debug-worker
flutter run -d chrome integration_test/web.dart
```

### Round-Trip Tests

```
cd example
flutter run test/ml_dsa_test.dart
```

or, for web:

```
cd example
make debug-worker
flutter run -d chrome test/web.dart
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
make debug-worker
flutter run -d chrome lib/web.dart
```

You can also build a `release-worker` which is minified and optimized:

```
cd example
make release-worker
```

## Performance

Performance should be comparable to `ml-dsa-dart` on most platforms, but web will be
slower.
