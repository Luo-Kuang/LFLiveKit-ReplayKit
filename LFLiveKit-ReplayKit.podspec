
Pod::Spec.new do |s|

  s.name         = "LFLiveKit-ReplayKit"
  s.version      = "0.0.1"
  s.summary      = "Forked form LFLiveKit, A ReplayKit Version"
  s.homepage     = "https://github.com/FranLucky/LFLiveKit-ReplayKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Pokeey" => "zhangfan8080@gmail.com" }
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/FranLucky/LFLiveKit-ReplayKit.git", :tag => "#{s.version}" }
  s.source_files  = "LFLiveKit-ReplayKit/**/*.{h,m,mm,cpp,c}"
  s.public_header_files = ['LFLiveKit-ReplayKit/*.h', 'LFLiveKit-ReplayKit/objects/*.h', 'LFLiveKit-ReplayKit/configuration/*.h']

  s.frameworks = "VideoToolbox", "AudioToolbox","AVFoundation","Foundation","UIKit"
  s.libraries = "c++", "z"

  s.requires_arc = true
end
