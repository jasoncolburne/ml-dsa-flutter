# ml_dsa_example

Demonstrates how to use the ml_dsa package.

## testing

`flutter test` doesn't build the keccak library. One can run all the tests with
`flutter run` for now.

### Known Answer Tests

```
flutter run integration_test/integration_test.dart
```

or, for web:

```
make debug-worker
flutter run -d chrome integration_test/web.dart
```

### Round-Trip Tests

```
flutter run test/ml_dsa_test.dart
```

or, for web:

```
make debug-worker
flutter run -d chrome test/web.dart
```

### Interactive app

A test app is also available,

```
flutter run lib/main.dart
```

or 

```
make debug-worker
flutter run -d chrome lib/web.dart
```

You can also build a `release-worker` which is minified and optimized:

```
make release-worker
```
