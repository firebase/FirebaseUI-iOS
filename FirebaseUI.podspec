Pod::Spec.new do |s|
  s.name         = 'FirebaseUI'
  s.version      = '0.5.1'
  s.summary      = 'UI binding libraries for Firebase.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache 2.0', :file => 'FirebaseUIFrameworks/LICENSE' }
  s.author       = 'Firebase'
  s.source       = { :http => 'https://github.com/firebase/FirebaseUI-iOS/releases/download/v0.5.1/FirebaseUIFrameworks.zip' }
  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.ios.framework = 'UIKit'
  s.requires_arc = true
  s.default_subspecs = 'All'
  s.ios.vendored_frameworks = 'FirebaseUIFrameworks/*/Frameworks/*.framework'

  s.subspec 'All' do |all|
    all.dependency 'FirebaseUI/Database'
    all.dependency 'FirebaseUI/Auth'
  end

  s.subspec 'Database' do |database|
    database.vendored_frameworks = ["FirebaseUIFrameworks/FirebaseDatabaseUI/Frameworks/FirebaseDatabaseUI.framework"]
    database.dependency 'Firebase/Database', '~> 3.0'
  end

  s.subspec 'Auth' do |auth|
    auth.dependency 'FirebaseUI/AuthBase'
    auth.dependency 'FirebaseUI/Facebook'
    auth.dependency 'FirebaseUI/Google'
  end

  s.subspec 'AuthBase' do |authbase|
    authbase.vendored_frameworks = ["FirebaseUIFrameworks/FirebaseAuthUI/Frameworks/FirebaseAuthUI.framework"]
    authbase.dependency 'Firebase/Analytics', '~> 3.0'
    authbase.dependency 'Firebase/Auth', '~> 3.0'
  end

  s.subspec 'Facebook' do |facebook|
    facebook.vendored_frameworks = ["FirebaseUIFrameworks/FirebaseFacebookAuthUI/Frameworks/FirebaseFacebookAuthUI.framework"]
    facebook.dependency 'FirebaseUI/AuthBase'
    facebook.dependency 'FBSDKLoginKit', '~> 4.0'
  end

  s.subspec 'Google' do |google|
    google.vendored_frameworks = ["FirebaseUIFrameworks/FirebaseGoogleAuthUI/Frameworks/FirebaseGoogleAuthUI.framework"]
    google.dependency 'FirebaseUI/AuthBase'
    google.dependency 'GoogleSignIn', '~> 4.0'
  end

end
