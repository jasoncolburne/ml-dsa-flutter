# ml_dsa

Module-Lattice-Based Digital Signature Standard

First, I created https://github.com/jasoncolburne/ml-dsa-go.
Then, I ported to dart in https://github.com/jasoncolburne/ml-dsa-dart.

Only tested for macOS, iOS, Android and Web.

I took implementations of Keccak from hashlib (for web/32-bit) and the
optimized reference in C (for 64-bit). I needed to modify them slightly to permit
some of the squeezing operations.

## Usage

Check the [example app](./example/README.md).

Generally, you probably want to use the `async.dart` extension and the `Async()`
functions everywhere but web.

For web, you can create a service worker capable of performing these operations
asynchronously to achieve the same effect.

These patterns are demonstrated in the example directory.

## Performance

Performance should be comparable to `ml-dsa-dart` on most platforms, but web will be
slower.
