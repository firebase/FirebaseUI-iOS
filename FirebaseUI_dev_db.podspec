Pod::Spec.new do |s|
  s.name         = 'FirebaseUI-db'
  s.version      = '0.5.4'
  s.summary      = 'UI binding libraries for Firebase.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache 2.0' }
  s.author       = 'Firebase'
  s.source = { :git => "../../FirebaseUI-iOS.git" }
  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.ios.framework = 'UIKit'
  s.requires_arc = true
  s.default_subspecs = 'Database'

  s.subspec 'Database' do |database|
    database.source_files = "FirebaseDatabaseUI/*.{h,m}"
    database.dependency 'Firebase/Database', '~> 3.0'
    database.ios.framework = 'FirebaseDatabase'
    database.xcconfig  = { 'FRAMEWORK_SEARCH_PATHS' => '"${PODS_ROOT}/FirebaseDatabase/Frameworks"','HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/Firebase/**"' }
  end

end
