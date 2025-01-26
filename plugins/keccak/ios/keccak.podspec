#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint keccak.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'keccak'
  s.version          = '1.0.0'
  s.summary          = 'The Keccak hash algorithm.'
  s.description      = <<-DESC
The Keccak hash algorithm.
                       DESC
  s.homepage         = 'http://github.com/jasoncolburne/ml-dsa-flutter/modules/keccak'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Jason Colburne' => 'email@example.com' }

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
