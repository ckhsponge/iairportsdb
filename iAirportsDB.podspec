#
# Be sure to run `pod lib lint iAirportsDB.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'iAirportsDB'
  s.version          = '3.1.0'
  s.summary          = 'Quickly find airports near a location'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Airports, heliports, seaplane bases, and balloonports can quickly be found near a location or by identifier. Supporting information such as runways and frequencies are provided. Information is global. The library is Swift but Objective C is supported. Behind the scenes Core Data using sqlite provides the framework for fast lookups.
                       DESC

  s.homepage         = 'https://github.com/ckhsponge/iAirportsDB'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Chris Hobbs' => 'purposemc@gmail.com' }
  s.source           = { :git => 'https://github.com/ckhsponge/iAirportsDB.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.3'

  s.source_files = 'iAirportsDB/Classes/**/*'
  
  s.resource_bundles = {
    'resourcebundle' => ['iAirportsDB/Assets/*']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  s.ios.deployment_target = '9.3'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '3.0'
end
