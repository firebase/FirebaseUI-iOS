Pod::Spec.new do |s|
  s.name         = 'FirebaseUI'
  s.version      = '4.5.1'
  s.summary      = 'UI binding libraries for Firebase.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.source       = { :git => 'https://github.com/firebase/FirebaseUI-iOS.git', :tag => 'v4.5.1' }
  s.author       = 'Firebase'
  s.platform = :ios
  s.ios.deployment_target = '9.0'
  s.static_framework = true
  s.ios.framework = 'UIKit'
  s.requires_arc = true
  s.public_header_files = 'FirebaseUI/FirebaseUI.h'
  s.source_files = 'FirebaseUI/FirebaseUI.h'
  s.cocoapods_version = '>= 1.4.0.beta.2'

  s.subspec 'Database' do |database|
    database.platform = :ios, '8.0'
    database.public_header_files = 'FirebaseDatabaseUI/*.h'
    database.source_files = 'FirebaseDatabaseUI/*.{h,m}'
    database.dependency 'Firebase/Database', '~> 4.0'
    database.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/FirebaseUI/FirebaseDatabaseUI' }
  end

  s.subspec 'Firestore' do |firestore|
    firestore.platform = :ios, '8.0'
    firestore.public_header_files = 'FirebaseFirestoreUI/*.h'
    firestore.source_files = 'FirebaseFirestoreUI/*.{h,m}'
    firestore.dependency 'Firebase/Firestore'
    firestore.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/FirebaseUI/FirebaseFirestoreUI' }
  end

  s.subspec 'Storage' do |storage|
    storage.platform = :ios, '8.0'
    storage.public_header_files = 'FirebaseStorageUI/*.h'
    storage.source_files = 'FirebaseStorageUI/*.{h,m}'
    storage.dependency 'Firebase/Storage', '~> 4.0'
    storage.dependency 'SDWebImage', '~> 4.0'
    storage.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/FirebaseUI/FirebaseStorageUI' }
  end

  s.subspec 'Auth' do |auth|
    auth.platform = :ios, '8.0'
    auth.public_header_files = ['FirebaseAuthUI/FirebaseAuthUI.h',
                                'FirebaseAuthUI/FUIAuth.h',
                                'FirebaseAuthUI/FUIAuthBaseViewController.h',
                                'FirebaseAuthUI/FUIAuthErrors.h',
                                'FirebaseAuthUI/FUIAuthErrorUtils.h',
                                'FirebaseAuthUI/FUIAuthPickerViewController.h',
                                'FirebaseAuthUI/FUIAuthProvider.h',
                                'FirebaseAuthUI/FUIEmailEntryViewController.h',
                                'FirebaseAuthUI/FUIPasswordRecoveryViewController.h',
                                'FirebaseAuthUI/FUIPasswordSignInViewController.h',
                                'FirebaseAuthUI/FUIPasswordSignUpViewController.h',
                                'FirebaseAuthUI/FUIPasswordVerificationViewController.h']
    auth.source_files = ['FirebaseAuthUI/**/*.{h,m}', 'FirebaseAuthUI/*.{h,m}']
    auth.dependency 'Firebase/Auth', '~> 4.2'
    auth.resource_bundle = {
      'FirebaseAuthUI' => ['FirebaseAuthUI/**/*.{xib,png,lproj}']
    }
    auth.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/FirebaseUI/FirebaseAuthUI' }
  end

  s.subspec 'Facebook' do |facebook|
    facebook.platform = :ios, '8.0'
    facebook.public_header_files = 'FirebaseFacebookAuthUI/*.h'
    facebook.source_files = 'FirebaseFacebookAuthUI/*.{h,m}'
    facebook.dependency 'FirebaseUI/Auth'
    facebook.dependency 'FBSDKLoginKit', '~> 4.0'
    facebook.resource_bundle = {
      'FirebaseFacebookAuthUI' => ['FirebaseFacebookAuthUI/**/*.{png,lproj}']
    }
    facebook.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/FirebaseUI/FirebaseFacebookAuthUI' }
  end

  s.subspec 'Google' do |google|
    google.platform = :ios, '8.0'
    google.public_header_files = 'FirebaseGoogleAuthUI/*.h'
    google.source_files = 'FirebaseGoogleAuthUI/*.{h,m}'
    google.dependency 'FirebaseUI/Auth'
    google.dependency 'GoogleSignIn', '~> 4.0'
    google.resource_bundle = {
      'FirebaseGoogleAuthUI' => ['FirebaseGoogleAuthUI/**/*.{png,lproj}']
    }
    google.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/FirebaseUI/FirebaseGoogleAuthUI' }
  end

  s.subspec 'Phone' do |phone|
    phone.platform = :ios, '8.0'
    phone.public_header_files = ['FirebasePhoneAuthUI/FirebasePhoneAuthUI.h',
                                 'FirebasePhoneAuthUI/FUIPhoneAuth.h']
    phone.source_files = 'FirebasePhoneAuthUI/**/*.{h,m}'
    phone.dependency 'FirebaseUI/Auth'
    phone.resource_bundle = {
      'FirebasePhoneAuthUI' => ['FirebasePhoneAuthUI/*.xib',
                                'FirebasePhoneAuthUI/**/*.{xib,json,lproj,png}']
    }
    phone.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/FirebaseUI/FirebasePhoneAuthUI' }
  end

  s.subspec 'Twitter' do |twitter|
    twitter.public_header_files = 'FirebaseTwitterAuthUI/*.h'
    twitter.source_files = 'FirebaseTwitterAuthUI/*.{h,m}'
    twitter.dependency 'FirebaseUI/Auth'
    twitter.dependency 'TwitterKit', '~> 3.0'
    twitter.platform = :ios, '9.0'
    twitter.resource_bundle = {
      'FirebaseTwitterAuthUI' => ['FirebaseTwitterAuthUI/**/*.{png,lproj}']
    }
    twitter.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/FirebaseUI/FirebaseTwitterAuthUI' }
  end
end
