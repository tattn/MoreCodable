Pod::Spec.new do |s|
  s.name             = 'MoreCodable'
  s.version          = '0.1.0'
  s.summary          = 'MoreCodable expands the possibilities of Codable.'

  s.description      = <<-DESC
MoreCodable expands the possibilities of Codable. 
It contains DictionaryEncoder/Decoder, URLQueryItemsEncoder/Decoder, ObjectMerger and so on...
                       DESC

  s.homepage         = 'https://github.com/tattn/MoreCodable'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'git' => 'tanakasan2525@gmail.com' }
  s.source           = { :git => 'https://github.com/tattn/MoreCodable.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tanakasan2525'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Sources/**/*'
  
  s.public_header_files = 'Sources/**/*.h'
  s.frameworks = 'Foundation'
end
