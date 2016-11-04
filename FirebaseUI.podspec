Pod::Spec.new do |s|
  s.name         = 'FirebaseUI'
  s.version      = '0.7.0'
  s.summary      = 'UI binding libraries for Firebase.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache 2.0', :file => 'FirebaseUIFrameworks/LICENSE' }
  s.source       = { :http => 'https://github.com/firebase/FirebaseUI-iOS/releases/download/v0.7.0/FirebaseUIFrameworks.zip' }
  s.author       = 'Firebase'
  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.ios.framework = 'UIKit'
  s.requires_arc = true
  s.default_subspecs = 'All'
  s.ios.vendored_frameworks = 'FirebaseUIFrameworks/*/Frameworks/*.framework'

  s.subspec 'All' do |all|
    all.dependency 'FirebaseUI/Database'
    all.dependency 'FirebaseUI/Storage'
    all.dependency 'FirebaseUI/Auth'
    all.dependency 'FirebaseUI/Facebook'
    all.dependency 'FirebaseUI/Google'
    all.dependency 'FirebaseUI/Twitter'
  end

  s.subspec 'Database' do |database|
    database.vendored_frameworks = ["FirebaseUIFrameworks/FirebaseDatabaseUI/Frameworks/FirebaseDatabaseUI.framework"]
    database.dependency 'Firebase/Database'
  end

  s.subspec 'Storage' do |storage|
    storage.vendored_frameworks = ["FirebaseUIFrameworks/FirebaseStorageUI/Frameworks/FirebaseStorageUI.framework"]
    storage.dependency 'Firebase/Storage'
    storage.dependency 'SDWebImage'
  end

  s.subspec 'Auth' do |auth|
    auth.vendored_frameworks = ["FirebaseUIFrameworks/FirebaseAuthUI/Frameworks/FirebaseAuthUI.framework"]
    auth.dependency 'Firebase/Auth'
    auth.resources = 'FirebaseUIFrameworks/FirebaseAuthUI/Frameworks/FirebaseAuthUI.framework/*.{nib,lproj,png}'
  end

  s.subspec 'Facebook' do |facebook|
    facebook.vendored_frameworks = ["FirebaseUIFrameworks/FirebaseFacebookAuthUI/Frameworks/FirebaseFacebookAuthUI.framework"]
    facebook.dependency 'FirebaseUI/Auth'
    facebook.dependency 'FBSDKLoginKit', '~> 4.0'
    facebook.resources = 'FirebaseUIFrameworks/FirebaseFacebookAuthUI/Frameworks/FirebaseFacebookAuthUI.framework/*.{nib,lproj,png}'
    facebook.user_target_xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(inherited) ${PODS_CONFIGURATION_BUILD_DIR}/FBSDKLoginKit' }
  end

  s.subspec 'Google' do |google|
    google.vendored_frameworks = ["FirebaseUIFrameworks/FirebaseGoogleAuthUI/Frameworks/FirebaseGoogleAuthUI.framework"]
    google.dependency 'FirebaseUI/Auth'
    google.dependency 'GoogleSignIn', '~> 4.0'
    google.resources = 'FirebaseUIFrameworks/FirebaseGoogleAuthUI/Frameworks/FirebaseGoogleAuthUI.framework/*.{nib,lproj,png}'
  end

  s.subspec 'Twitter' do |twitter|
    twitter.vendored_frameworks = ["FirebaseUIFrameworks/FirebaseTwitterAuthUI/Frameworks/FirebaseTwitterAuthUI.framework"]
    twitter.dependency 'FirebaseUI/Auth'
    twitter.dependency 'TwitterKit', '~> 2.4'
    twitter.resources = 'FirebaseUIFrameworks/FirebaseTwitterAuthUI/Frameworks/FirebaseTwitterAuthUI.framework/*.{nib,lproj,png}'
  end
end
