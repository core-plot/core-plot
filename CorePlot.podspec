Pod::Spec.new do |s|
  s.name     = 'CorePlot'
  s.version  = '2.3'
  s.license  = 'BSD'
  s.summary  = 'Cocoa plotting framework for macOS, iOS, and tvOS.'
  s.homepage = 'https://github.com/core-plot'
  s.social_media_url  = 'https://twitter.com/CorePlot'
  s.documentation_url = 'https://core-plot.github.io'
 
  s.authors  = { 'Drew McCormack' => 'drewmccormack@mac.com',
                 'Brad Larson'    => 'larson@sunsetlakesoftware.com',
                 'Eric Skroch'    => 'eskroch@mac.com',
                 'Barry Wark'     => 'barrywark@gmail.com' }

  s.source   = { :git => 'https://github.com/core-plot/core-plot.git', :tag => 'release_2.3'}

  s.description = 'Core Plot is a plotting framework for macOS, iOS, and tvOS. It provides 2D visualization ' \
                  'of data, and is tightly integrated with Apple technologies like Core Animation, ' \
                  'Core Data, and Cocoa Bindings.'

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'
  
  s.ios.header_dir = 'ios'
  s.osx.header_dir = 'osx'
  s.tvos.header_dir = 'tvos'
  
  s.source_files = 'framework/Source/*.{h,m}', 'framework/CocoaPods/*.h'
  s.exclude_files = '**/*{TestCase,Tests}.{h,m}', '**/mainpage.h'
  s.ios.source_files = 'framework/CorePlot-CocoaTouch.h', 'framework/PlatformSpecific/*.{h,m}'
  s.tvos.source_files = 'framework/PlatformSpecific/*.{h,m}'
  s.osx.source_files = 'framework/MacOnly/*.{h,m}', 'framework/PlatformSpecific/*.{h,m}'
  s.private_header_files = '**/_*.h'

  s.requires_arc  = true
  s.ios.xcconfig  = { 'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/Headers/Private/CorePlot/ios"' }
  s.osx.xcconfig  = { 'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/Headers/Private/CorePlot/osx"' }
  s.tvos.xcconfig = { 'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/Headers/Private/CorePlot/tvos"' }
  
  s.frameworks     = 'QuartzCore'
  s.ios.frameworks = 'UIKit', 'Foundation'
  s.tvos.frameworks = 'UIKit', 'Foundation'
  s.osx.frameworks = 'Cocoa'
end