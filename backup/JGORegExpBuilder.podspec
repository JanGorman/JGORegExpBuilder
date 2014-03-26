Pod::Spec.new do |s|
  s.name             = "JGORegExpBuilder"
  s.version          = "1.0.0"
  s.summary          = "A delightful regular expression DSL"
  s.homepage         = "https://github.com/JanGorman/JGORegExpBuilder"
  s.license          = 'MIT'
  s.author           = { "Jan Gorman" => "gorman.jan@gmail.com" }
  s.source           = { :git => "https://github.com/JanGorman/JGORegExpBuilder.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/JanGorman'

  s.requires_arc = true
  s.source_files = 'Classes'
end
