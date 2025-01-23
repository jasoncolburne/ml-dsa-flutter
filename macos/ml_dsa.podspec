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

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'ml_dsa_privacy' => ['Resources/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
