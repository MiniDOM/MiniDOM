Pod::Spec.new do |s|

  s.name         = "MiniDOM"
  s.version      = "1.0.0"
  s.summary      = "A minimal XML DOM parser for Swift."

  s.homepage     = "https://minidom.github.io/"

  s.license      = { :type => "Apache", :file => "LICENSE" }
  s.author       =  "Paul Calnan"

  s.ios.deployment_target = "8.4"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"

  s.source        = { :git => "https://github.com/MiniDOM/MiniDOM.git", :tag => "#{s.version}" }
  s.source_files  = "Sources"
  s.exclude_files = ["Examples", "Tests"]

  s.documentation_url = "https://minidom.github.io/Documentation"

end
