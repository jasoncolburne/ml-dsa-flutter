# ml_dsa_example

Demonstrates how to use the ml_dsa package.

## Sample apps

Mobile:

```
flutter run lib/main.dart
```

Web:

```
make debug-worker
flutter run -d chrome lib/web.dart
```

## Testing

To run all integration tests for non-web platforms:

```
flutter test integration_test/*
```

## Web Tests

The same integration tests exist for web, and are found in the `/web_test` directory.

### Known Answer Tests

```
make debug-worker
flutter run -d chrome web_test/kat.dart
```

### Round-Trip Tests

```
make debug-worker
flutter run -d chrome web_test/roundtrip.dart
```

## Service worker

Examples above use the `debug-worker` make target, which is undesired in production.

You can also build a `release-worker` which is minified and optimized:

```
make release-worker
```
