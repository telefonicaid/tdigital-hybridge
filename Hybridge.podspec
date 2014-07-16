Pod::Spec.new do |s|
  s.name         = "Hybridge"
  s.version      = "1.2.0"
  s.summary      = "Yet another javascript / mobile native simple bridge for hybrid apps, back and forth..."

  s.description  = <<-DESC
                   When developing hybrid apps surely you'll need to access different native features and resources. 
                   Out there are plenty of bridge solutions. Hybridge tries to make easy communication and data 
                   exchanging between native (iOS & Android) and Javascript worlds, avoiding too much overhead.
                   DESC
  s.homepage     = "https://github.com/telefonicaid/tdigital-hybridge"
  
  s.license      = { :type => "Affero GNU GPL v3", :file => "LICENSE.txt" }

  s.authors  = { 'David Garcia' => 'davidgarsan@gmail.com', 'Guillermo Gonzalez' => 'gonzalezreal@icloud.com' }

  s.platform     = :ios
  s.ios.deployment_target = "6.0"
  s.source       = { :git => "https://github.com/telefonicaid/tdigital-hybridge.git", :tag => "1.2.0" }

  s.source_files = "ios/Hybridge/Hybridge/*.{h,m}"
  s.private_header_files = "ios/Hybridge/Hybridge/HYBURLProtocol.h", "ios/Hybridge/Hybridge/NSString+Hybridge.h"
  
  s.frameworks = "Foundation", "UIKit"
  s.requires_arc = true
end
