Pod::Spec.new do |s|
  s.name     = 'CorePlot'
  s.version  = '2.4'
  s.license  = 'BSD'
  s.summary  = 'Cocoa plotting framework for macOS, iOS, and tvOS.'
  s.homepage = 'https://github.com/core-plot'
  s.social_media_url  = 'https://twitter.com/CorePlot'
  s.documentation_url = 'https://core-plot.github.io'
 
  s.authors  = { 'Drew McCormack' => 'drewmccormack@mac.com',
                 'Brad Larson'    => 'larson@sunsetlakesoftware.com',
                 'Eric Skroch'    => 'eskroch@mac.com',
                 'Barry Wark'     => 'barrywark@gmail.com' }

  s.source   = { :git => 'https://github.com/core-plot/core-plot.git', :branch => 'release-2.4' }

  s.description = 'Core Plot is a plotting framework for macOS, iOS, and tvOS. It provides 2D visualization ' \
                  'of data, and is tightly integrated with Apple technologies like Core Animation, ' \
                  'Core Data, and Cocoa Bindings.'

  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.13'
  s.tvos.deployment_target = '12.0'
  
  s.ios.header_dir = 'ios'
  s.osx.header_dir = 'osx'
  s.tvos.header_dir = 'tvos'
  
  s.source_files = 'framework/*CorePlot*.h', 'framework/Source/*.{h,m}', 'framework/PlatformSpecific/*.{h,m}'
  s.exclude_files = '**/*{TestCase,Tests}.{h,m}', '**/mainpage.h'
  s.project_header_files = '**/_*.h'

  s.requires_arc  = true

  s.module_map = false

  s.xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.ios.xcconfig  = { 'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/Headers/Private/CorePlot/ios"' }
  s.osx.xcconfig  = { 'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/Headers/Private/CorePlot/osx"' }
  s.tvos.xcconfig = { 'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/Headers/Private/CorePlot/tvos"' }

  s.frameworks     = 'QuartzCore'
  s.ios.frameworks = 'UIKit', 'Foundation'
  s.osx.frameworks = 'Cocoa'
  s.tvos.frameworks = 'UIKit', 'Foundation'
end