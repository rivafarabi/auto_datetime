Pod::Spec.new do |s|
  s.name             = 'auto_datetime'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin to check if automatic date/time is enabled.'
  s.description      = <<-DESC
A Flutter plugin that detects whether the device uses automatic date and time settings.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
