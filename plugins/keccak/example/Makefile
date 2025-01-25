.PHONY: service-worker

service-worker:
	flutter pub run build_runner build --delete-conflicting-outputs
	cp .dart_tool/build/generated/keccak_example/lib/sw.dart.js web
