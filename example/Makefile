.PHONY: debug-worker release-worker

debug-worker:
	flutter pub run build_runner build --delete-conflicting-outputs
	cp .dart_tool/build/generated/ml_dsa_example/lib/sw.dart.js web

release-worker:
	flutter pub run build_runner build --delete-conflicting-outputs --release
	cp .dart_tool/build/generated/ml_dsa_example/lib/sw.dart.js web
