Pod::Spec.new do |s|
  s.name             = "ArexKit"
  s.version          = "0.0.1"
  s.summary          = "ArexKit is the backend for Arex. It's the medicine cabinet, if you will"
  s.homepage         = "https://github.com/a2/arex-7"
  s.license          = 'MIT'
  s.author           = { "Alexsander Akers" => "me@a2.io" }
  s.source           = { :git => "https://github.com/a2/arex-7.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/a2'
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'ArexKit/**/*.swift'
  s.dependency 'Gulliver', '0.0.1'
  s.dependency 'MessagePack.swift', '0.1.0'
  s.dependency 'Pistachio', '0.1.1-a2'
  s.dependency 'ReactiveCocoa', '3.0-alpha.3'
end
