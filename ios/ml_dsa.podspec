#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ml_dsa.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ml_dsa'
  s.version          = '0.0.1'
  s.summary          = 'Module-Lattice-Based Digital Signature Standard'
  s.description      = <<-DESC
Module-Lattice-Based Digital Signature Standard for Flutter.
                       DESC
  s.homepage         = 'https://github.com/jasoncolburne/ml-dsa-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Jason Colburne' => 'xxx@xxx.xx' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
