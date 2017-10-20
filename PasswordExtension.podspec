#
# Be sure to run `pod lib lint PasswordExtension.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PasswordExtension'
  s.version          = '4.0.3'
  s.summary          = 'Let users use a third party password manager right in your own app.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'PasswordExtension lets you give users access to their third party password manager conforming the PasswordExtension scheme (i.e. 1Password, LastPass) to fill in their login credentials from their vault, add credentials to their vault, and change their password in their vault for any given url.'

  s.homepage         = 'https://github.com/fahlout/PasswordExtension'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Niklas Fahl' => 'niklas.fahl@me.com' }
  s.source           = { :git => 'https://github.com/fahlout/PasswordExtension.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'PasswordExtension/Classes/**/*'
  
  # s.resource_bundles = {
  #   'PasswordExtension' => ['PasswordExtension/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
