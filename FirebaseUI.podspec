Pod::Spec.new do |s|
  s.name         = 'FirebaseUI'
  s.version      = '0.4.0'
  s.summary      = 'UI binding libraries for Firebase.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author       = { 'Firebase' => 'support@firebase.com' }
  s.source       = { :http => 'https://storage.googleapis.com/gcpstatic/FirebaseUIFrameworks.zip' }
  s.platform = :ios
  s.ios.deployment_target = '7.0'
  s.ios.framework = 'UIKit'
  s.requires_arc = true
  s.default_subspecs = 'All'

  s.subspec 'All' do |all|
    all.dependency 'FirebaseUI/Database'
    all.dependency 'FirebaseUI/Auth'
  end

  s.subspec 'Database' do |database|
    database.vendored_frameworks = ["FirebaseUIFrameworks/Database/Frameworks/FirebaseDatabaseUI.framework"]
    database.dependency 'Firebase/Database', '~> 3.0'
  end

  s.subspec 'Auth' do |auth|
    auth.dependency 'FirebaseUI/AuthBase'
    auth.dependency 'FirebaseUI/Facebook'
    auth.dependency 'FirebaseUI/Google'
  end

  s.subspec 'AuthBase' do |authbase|
    authbase.vendored_frameworks = ["FirebaseUIFrameworks/Auth/Frameworks/FirebaseAuthUI.framework"]
    authbase.resources = ["FirebaseUIFrameworks/Auth/Resources/FirebaseAuthUIBundle.bundle"]
    authbase.dependency 'Firebase/Analytics', '~> 3.0'
    authbase.dependency 'Firebase/Auth', '~> 3.0'
  end

  s.subspec 'Facebook' do |facebook|
    facebook.vendored_frameworks = ["FirebaseUIFrameworks/Facebook/Frameworks/FirebaseFacebookAuthUI.framework"]
    facebook.resources = ["FirebaseUIFrameworks/Facebook/Resources/FirebaseFacebookAuthUI.bundle"]
    facebook.dependency 'FirebaseUI/AuthBase'
    facebook.dependency 'FBSDKLoginKit', '~> 4.0'
  end

  s.subspec 'Google' do |google|
    google.vendored_frameworks = ["FirebaseUIFrameworks/Google/Frameworks/FirebaseGoogleAuthUI.framework"]
    google.resources = ["FirebaseUIFrameworks/Google/Resources/FirebaseGoogleAuthUI.bundle"]
    google.dependency 'FirebaseUI/AuthBase'
    google.dependency 'GoogleSignIn', '~> 4.0'
  end

end
