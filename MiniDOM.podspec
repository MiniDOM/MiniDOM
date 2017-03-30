#
#  Be sure to run `pod spec lint MiniDOM.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
Pod::Spec.new do |s|

  s.name         = "MiniDOM"
  s.version      = "0.9.4"
  s.summary      = "A minimal XML DOM parser for Swift."

  s.homepage     = "https://minidom.github.io/"

  s.license      = { :type => "Apache", :file => "LICENSE" }
  s.author       =  "Paul Calnan"

  s.ios.deployment_target = "8.4"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"

  s.source       = { :git => "https://github.com/MiniDOM/MiniDOM.git", :tag => "#{s.version}" }
  s.source_files  = "Sources"
  s.exclude_files = "Tests"

end
