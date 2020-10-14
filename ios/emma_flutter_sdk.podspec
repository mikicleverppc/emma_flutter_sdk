#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint emma_flutter_sdk.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'emma_flutter_sdk'
  s.version          = '1.0.0'
  s.summary          = 'EMMA SDK implementation for flutter'
  s.description      = <<-DESC
  EMMA SDK implementation for flutter
                       DESC
  s.homepage         = 'http://www.emmaio'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'EMMA MOBILE SOLUTIONS SL' => 'info@emma.io' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # dependencies
  s.dependency 'eMMa'
end
