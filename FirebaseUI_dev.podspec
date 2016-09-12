Pod::Spec.new do |s|
  s.name         = 'FirebaseUI'
  s.version      = '0.5.2'
  s.summary      = 'UI binding libraries for Firebase.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache 2.0' }
  s.author       = 'Firebase'
  s.source = { :git => "../../FirebaseUI-iOS.git" }
  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.ios.framework = 'UIKit'
  s.requires_arc = true
  s.default_subspecs = 'All'

  s.subspec 'All' do |all|
    all.dependency 'FirebaseUI/Database'
    all.dependency 'FirebaseUI/Auth'
  end

  s.subspec 'Database' do |database|
    database.source_files = "FirebaseDatabaseUI/*.{h,m}"
    database.dependency 'Firebase/Database', '~> 3.0'
    database.ios.framework = 'FirebaseDatabase'
    database.xcconfig  = { 'FRAMEWORK_SEARCH_PATHS' => '"${PODS_ROOT}/FirebaseDatabase/Frameworks"','HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/Firebase/**"' }
  end

  s.subspec 'Auth' do |auth|
    auth.dependency 'FirebaseUI/AuthBase'
    auth.dependency 'FirebaseUI/Facebook'
    auth.dependency 'FirebaseUI/Google'
  end

  s.subspec 'AuthBase' do |authbase|
    authbase.source_files = "FirebaseAuthUI/*.{h,m}"
    authbase.resources = "FirebaseAuthUI/{Resources,Strings}/*", "FirebaseAuthUI/*.xib"
    authbase.dependency 'Firebase/Analytics', '~> 3.0'
    authbase.dependency 'Firebase/Auth', '~> 3.0'
  end

  s.subspec 'Facebook' do |facebook|
    facebook.source_files = "FirebaseFacebookAuthUI/*.{h,m}"
    facebook.resources = "FirebaseFacebookAuthUI/{Resources,Strings}/*", "FirebaseFacebookAuthUI/*.xib"
    facebook.dependency 'FirebaseUI/AuthBase'
    facebook.dependency 'FBSDKLoginKit', '~> 4.0'
  end

  s.subspec 'Google' do |google|
    google.source_files = "FirebaseGoogleAuthUI/*.{h,m}"
    google.resources = "FirebaseGoogleAuthUI/{Resources,Strings}/*", "FirebaseGoogleAuthUI/*.xib"
    google.dependency 'FirebaseUI/AuthBase'
    google.dependency 'GoogleSignIn', '~> 4.0'
  end

end
