Pod::Spec.new do |spec|
  spec.name         = 'NgEventer'
  spec.version      = '1.0'
  spec.summary      = 'A better objective-c library for building event-driven system.'
  spec.homepage     = 'https://github.com/meiwin/NgEventer'
  spec.author       = { 'Meiwin Fu' => 'meiwin@blockthirty.com' }
  spec.source       = { :git => 'https://github.com/meiwin/ngeventer.git', :tag => "v#{spec.version}" }
  spec.source_files = 'NgEventer/**/*.{h,m}'
  spec.requires_arc = true
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.frameworks   = 'UIKit'
  spec.ios.deployment_target = "8.0"
end