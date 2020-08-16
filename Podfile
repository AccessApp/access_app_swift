workspace 'access-app-swift'
platform :ios, '11.0'
use_frameworks!

target 'places' do
  pod 'Firebase/Analytics'
  pod 'SwiftJWT'
  project 'places/places.xcodeproj'
end

target 'visitor' do
  pod 'Firebase/Analytics'
  pod 'SwiftJWT'
  project 'visitor/visitor.xcodeproj'
  
  post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
  end
end
