#
# Be sure to run `pod spec lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "JGORegExpBuilder"
  s.version          = "0.1.0"
  s.summary          = "A delightful regular expression DSL"
  s.description      = <<-DESC
                       An optional longer description of JGORegExpBuilder

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "http://github.com/JanGorman/JGORegExpBuilder"
  s.license          = 'MIT'
  s.author           = { "Jan Gorman" => "gorman.jan@gmail.com" }
  s.source           = { :git => "http://github.com/JanGorman/JGORegExpBuilder.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/JanGorman'

  # s.ios.deployment_target = '7.0'
  s.requires_arc = true

  s.source_files = 'Classes'
  # s.resources = 'Resources'

  # s.ios.exclude_files = 'Classes/osx'
  # s.osx.exclude_files = 'Classes/ios'
  # s.public_header_files = 'Classes/*.h'
end
