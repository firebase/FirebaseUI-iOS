Pod::Spec.new do |s|
  s.name         = 'FirebaseUI'
  s.version      = '4.5.1'
  s.summary      = 'UI binding libraries for Firebase.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache 2.0', :file => 'FirebaseUIFrameworks/LICENSE' }
  s.source       = { :http => 'https://github.com/firebase/FirebaseUI-iOS/releases/download/v4.5.1/FirebaseUIFrameworks.zip' }
  s.author       = 'Firebase'
  s.platform = :ios
  s.ios.deployment_target = '9.0'
  s.ios.framework = 'UIKit'
  s.requires_arc = true
  s.default_subspecs = 'All'
  s.ios.vendored_frameworks = 'FirebaseUIFrameworks/*/Frameworks/*.framework'

  s.subspec 'All' do |all|
    all.platform = :ios, '9.0'
    all.dependency 'FirebaseUI/Database'
    all.dependency 'FirebaseUI/Storage'
    all.dependency 'FirebaseUI/Auth'
    all.dependency 'FirebaseUI/Facebook'
    all.dependency 'FirebaseUI/Google'
    all.dependency 'FirebaseUI/Phone'
    all.dependency 'FirebaseUI/Twitter'
    all.dependency 'FirebaseUI/Firestore'
  end

  s.subspec 'Database' do |database|
    database.platform = :ios, '8.0'
    database.vendored_frameworks = ["FirebaseUIFrameworks/FirebaseDatabaseUI/Frameworks/FirebaseDatabaseUI.framework"]
    database.dependency 'Firebase/Database', '~> 4.0'
  end

  s.subspec 'Firestore' do |firestore|
    firestore.platform = :ios, '8.0'
    firestore.vendored_frameworks = ["FirebaseUIFrameworks/FirebaseFirestoreUI/Frameworks/FirebaseFirestoreUI.framework"]
    firestore.dependency 'Firebase/Firestore'
  end

  s.subspec 'Storage' do |storage|
    storage.platform = :ios, '8.0'
    storage.vendored_frameworks = ["FirebaseUIFrameworks/FirebaseStorageUI/Frameworks/FirebaseStorageUI.framework"]
    storage.dependency 'Firebase/Storage', '~> 4.0'
    storage.dependency 'SDWebImage', '~> 4.0'
  end

  s.subspec 'Auth' do |auth|
    auth.platform = :ios, '8.0'
    auth.vendored_frameworks = ["FirebaseUIFrameworks/FirebaseAuthUI/Frameworks/FirebaseAuthUI.framework"]
    auth.dependency 'Firebase/Auth', '~> 4.2'
    auth.resource_bundle = {
      'FirebaseAuthUI' => ['FirebaseUIFrameworks/FirebaseAuthUI/Frameworks/FirebaseAuthUI.framework/*.nib',
                           'FirebaseUIFrameworks/FirebaseAuthUI/Frameworks/FirebaseAuthUI.framework/*.lproj',
                           'FirebaseUIFrameworks/FirebaseAuthUI/Frameworks/FirebaseAuthUI.framework/*.png']
    }
  end

  s.subspec 'Facebook' do |facebook|
    facebook.platform = :ios, '8.0'
    facebook.vendored_frameworks = ["FirebaseUIFrameworks/FirebaseFacebookAuthUI/Frameworks/FirebaseFacebookAuthUI.framework"]
    facebook.dependency 'FirebaseUI/Auth'
    facebook.dependency 'FBSDKLoginKit', '~> 4.0'
    facebook.resource_bundle = {
      'FirebaseFacebookAuthUI' => ['FirebaseUIFrameworks/FirebaseFacebookAuthUI/Frameworks/FirebaseFacebookAuthUI.framework/*.nib',
                                   'FirebaseUIFrameworks/FirebaseFacebookAuthUI/Frameworks/FirebaseFacebookAuthUI.framework/*.lproj',
                                   'FirebaseUIFrameworks/FirebaseFacebookAuthUI/Frameworks/FirebaseFacebookAuthUI.framework/*.png']
    }
  end

  s.subspec 'Google' do |google|
    google.platform = :ios, '8.0'
    google.vendored_frameworks = ["FirebaseUIFrameworks/FirebaseGoogleAuthUI/Frameworks/FirebaseGoogleAuthUI.framework"]
    google.dependency 'FirebaseUI/Auth'
    google.dependency 'GoogleSignIn', '~> 4.0'
    google.resource_bundle = {
      'FirebaseGoogleAuthUI' => ['FirebaseUIFrameworks/FirebaseGoogleAuthUI/Frameworks/FirebaseGoogleAuthUI.framework/*.nib',
                                 'FirebaseUIFrameworks/FirebaseGoogleAuthUI/Frameworks/FirebaseGoogleAuthUI.framework/*.lproj',
                                 'FirebaseUIFrameworks/FirebaseGoogleAuthUI/Frameworks/FirebaseGoogleAuthUI.framework/*.png']
    }
  end

  s.subspec 'Phone' do |phone|
    phone.platform = :ios, '8.0'
    phone.vendored_frameworks = ["FirebaseUIFrameworks/FirebasePhoneAuthUI/Frameworks/FirebasePhoneAuthUI.framework"]
    phone.dependency 'FirebaseUI/Auth'
    phone.resource_bundle = {
      'FirebasePhoneAuthUI' => ['FirebaseUIFrameworks/FirebasePhoneAuthUI/Frameworks/FirebasePhoneAuthUI.framework/*.nib',
                                'FirebaseUIFrameworks/FirebasePhoneAuthUI/Frameworks/FirebasePhoneAuthUI.framework/*.lproj',
                                'FirebaseUIFrameworks/FirebasePhoneAuthUI/Frameworks/FirebasePhoneAuthUI.framework/*.png',
                                'FirebaseUIFrameworks/FirebasePhoneAuthUI/Frameworks/FirebasePhoneAuthUI.framework/*.json']
    }
  end

  s.subspec 'Twitter' do |twitter|
    twitter.vendored_frameworks = ["FirebaseUIFrameworks/FirebaseTwitterAuthUI/Frameworks/FirebaseTwitterAuthUI.framework"]
    twitter.dependency 'FirebaseUI/Auth'
    twitter.dependency 'TwitterKit', '~> 3.0'
    twitter.platform = :ios, '9.0'
    twitter.resource_bundle = {
      'FirebaseTwitterAuthUI' => ['FirebaseUIFrameworks/FirebaseTwitterAuthUI/Frameworks/FirebaseTwitterAuthUI.framework/*.nib',
                                  'FirebaseUIFrameworks/FirebaseTwitterAuthUI/Frameworks/FirebaseTwitterAuthUI.framework/*.lproj',
                                  'FirebaseUIFrameworks/FirebaseTwitterAuthUI/Frameworks/FirebaseTwitterAuthUI.framework/*.png']
    }
  end
end
