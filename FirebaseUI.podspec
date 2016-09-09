Pod::Spec.new do |s|
  s.name         = 'FirebaseUI'
  s.version      = '0.5.2'
  s.summary      = 'UI binding libraries for Firebase.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache 2.0', :file => 'FirebaseUIFrameworks/LICENSE' }
  s.author       = 'Firebase'
  s.source       = { :http => 'https://dl.google.com/dl/firebase/firebaseui/ios/0_5_0/FirebaseUIFrameworks.zip' }
  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.ios.framework = 'UIKit'
  s.requires_arc = true
  s.default_subspecs = 'All'
  s.ios.vendored_frameworks = 'FirebaseUIFrameworks/*/Frameworks/*.framework'

  s.subspec 'All' do |all|
    all.dependency 'FirebaseUI/Database'
    all.dependency 'FirebaseUI/Auth'
    all.dependency 'FirebaseUI/Facebook'
    all.dependency 'FirebaseUI/Google'
  end

  s.subspec 'Database' do |database|
    database.source_files = 'FirebaseDatabaseUI/*.{h,m}'
    database.dependency 'Firebase/Database'
  end

  s.subspec 'Auth' do |auth|
    auth.source_files = 'FirebaseAuthUI/*.{h,m}'
    auth.resource_bundles = { 'FirebaseAuthUIBundle' => [ 'FirebaseAuthUI/Resources/*', 'FirebaseAuthUI/*.xib', 'FirebaseAuthUI/Strings/**/*.strings' ] }
    auth.dependency 'Firebase/Auth'
  end

  s.subspec 'Facebook' do |facebook|
    facebook.source_files = 'FirebaseFacebookAuthUI/*.{h,m}'
    facebook.resource_bundles = { 'FirebaseFacebookAuthUIBundle' => [ 'FirebaseFacebookAuthUI/Resources/*', 'FirebaseFacebookAuthUI/Strings/**/*.strings' ] }
    facebook.dependency 'FirebaseUI/Auth'
    facebook.dependency 'FBSDKLoginKit', '~> 4.0'
  end

  s.subspec 'Google' do |google|
    google.source_files = 'FirebaseGoogleAuthUI/*.{h,m}'
    google.resource_bundles = { 'FirebaseGoogleAuthUIBundle' => [ 'FirebaseGoogleAuthUI/Resources/*', 'FirebaseFacebookAuthUI/Strings/**/*.strings' ] }
    google.dependency 'FirebaseUI/Auth'
    google.dependency 'GoogleSignIn', '~> 4.0'
  end
end
