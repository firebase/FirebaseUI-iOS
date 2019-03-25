Pod::Spec.new do |s|
  s.name         = 'FirebaseUI'
  s.version      = '6.2.1'
  s.summary      = 'UI binding libraries for Firebase.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.source       = { :git => 'https://github.com/firebase/FirebaseUI-iOS.git', :tag => 'v' + s.version.to_s }
  s.author       = 'Firebase'
  s.platform = :ios
  s.ios.deployment_target = '9.0'
  s.static_framework = true
  s.ios.framework = 'UIKit'
  s.requires_arc = true
  s.public_header_files = 'FirebaseUI.h'
  s.source_files = 'FirebaseUI.h'
  s.cocoapods_version = '>= 1.5.0'

  s.subspec 'Database' do |database|
    database.platform = :ios, '8.0'
    database.public_header_files = 'Database/FirebaseDatabaseUI/*.h'
    database.source_files = 'Database/FirebaseDatabaseUI/*.{h,m}'
    database.dependency 'Firebase/Database', '~> 5.0'
    database.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/FirebaseUI/FirebaseDatabaseUI' }
  end

  s.subspec 'Firestore' do |firestore|
    firestore.platform = :ios, '8.0'
    firestore.public_header_files = 'Firestore/FirebaseFirestoreUI/*.h'
    firestore.source_files = 'Firestore/FirebaseFirestoreUI/*.{h,m}'
    firestore.dependency 'Firebase/Firestore'
    firestore.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/FirebaseUI/FirebaseFirestoreUI' }
  end

  s.subspec 'Storage' do |storage|
    storage.platform = :ios, '8.0'
    storage.public_header_files = 'Storage/FirebaseStorageUI/*.h'
    storage.source_files = 'Storage/FirebaseStorageUI/*.{h,m}'
    storage.dependency 'Firebase/Storage', '~> 5.0'
    storage.dependency 'SDWebImage', '~> 4.0'
    storage.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/FirebaseUI/FirebaseStorageUI' }
  end

  s.subspec 'Auth' do |auth|
    auth.platform = :ios, '8.0'
    auth.public_header_files = ['Auth/FirebaseAuthUI/AccountManagement/FUIAccountSettingsOperationType.h',
                                'Auth/FirebaseAuthUI/AccountManagement/FUIAccountSettingsViewController.h',
                                'Auth/FirebaseAuthUI/FirebaseAuthUI.h',
                                'Auth/FirebaseAuthUI/FUIAuth.h',
                                'Auth/FirebaseAuthUI/FUIAuth_Internal.h',
                                'Auth/FirebaseAuthUI/FUIAuthBaseViewController.h',
                                'Auth/FirebaseAuthUI/FUIAuthBaseViewController_Internal.h',
                                'Auth/FirebaseAuthUI/FUIAuthErrors.h',
                                'Auth/FirebaseAuthUI/FUIAuthErrorUtils.h',
                                'Auth/FirebaseAuthUI/FUIAuthPickerViewController.h',
                                'Auth/FirebaseAuthUI/FUIAuthProvider.h',
                                'Auth/FirebaseAuthUI/FUIEmailEntryViewController.h',
                                'Auth/FirebaseAuthUI/FUIPasswordRecoveryViewController.h',
                                'Auth/FirebaseAuthUI/FUIPasswordSignInViewController.h',
                                'Auth/FirebaseAuthUI/FUIPasswordSignUpViewController.h',
                                'Auth/FirebaseAuthUI/FUIPasswordVerificationViewController.h',
                                'Auth/FirebaseAuthUI/FUIAuthUtils.h',
                                'Auth/FirebaseAuthUI/FUIAuthStrings.h',
                                'Auth/FirebaseAuthUI/FUIPrivacyAndTermsOfServiceView.h',
                                'Auth/FirebaseAuthUI/FUIAuthTableViewCell.h',
                                'Auth/FirebaseAuthUI/FUIAuthTableHeaderView.h']
    auth.source_files = ['Auth/FirebaseAuthUI/**/*.{h,m}', 'Auth/FirebaseAuthUI/*.{h,m}']
    auth.dependency 'Firebase/Auth', '~> 5.4'
    auth.dependency 'GoogleUtilities/UserDefaults'
    auth.resource_bundle = {
      'FirebaseAuthUI' => ['Auth/FirebaseAuthUI/**/*.{xib,png,lproj}']
    }
    auth.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/FirebaseUI/FirebaseAuthUI' }
  end

  s.subspec 'Anonymous' do |anonymous|
    anonymous.platform = :ios, '8.0'
    anonymous.public_header_files = 'AnonymousAuth/FirebaseAnonymousAuthUI/*.h'
    anonymous.source_files = 'AnonymousAuth/FirebaseAnonymousAuthUI/*.{h,m}'
    anonymous.dependency 'FirebaseUI/Auth'
    anonymous.resource_bundle = {
      'FirebaseAnonymousAuthUI' => ['AnonymousAuth/FirebaseAnonymousAuthUI/**/*.{png,lproj}']
    }
    anonymous.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/FirebaseUI/FirebaseAnonymousAuthUI' }
  end

  s.subspec 'Email' do |email|
    email.platform = :ios, '8.0'
    email.public_header_files = ['EmailAuth/FirebaseEmailAuthUI/FirebaseEmailAuthUI.h',
                                 'EmailAuth/FirebaseEmailAuthUI/FUIConfirmEmailViewController.h',
                                 'EmailAuth/FirebaseEmailAuthUI/FUIEmailAuth.h',
                                 'EmailAuth/FirebaseEmailAuthUI/FUIEmailEntryViewController.h',
                                 'EmailAuth/FirebaseEmailAuthUI/FUIPasswordRecoveryViewController.h',
                                 'EmailAuth/FirebaseEmailAuthUI/FUIPasswordSignInViewController.h',
                                 'EmailAuth/FirebaseEmailAuthUI/FUIPasswordSignUpViewController.h',
                                 'EmailAuth/FirebaseEmailAuthUI/FUIPasswordVerificationViewController.h']
    email.source_files = 'EmailAuth/FirebaseEmailAuthUI/**/*.{h,m}'
    email.dependency 'FirebaseUI/Auth'
    email.resource_bundle = {
      'FirebaseEmailAuthUI' => ['EmailAuth/FirebaseEmailAuthUI/*.xib',
                                'EmailAuth/FirebaseEmailAuthUI/**/*.{xib,json,lproj,png}']
    }
    email.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/FirebaseUI/FirebaseEmailAuthUI' }
  end


  s.subspec 'Facebook' do |facebook|
    facebook.platform = :ios, '8.0'
    facebook.public_header_files = 'FacebookAuth/FirebaseFacebookAuthUI/*.h'
    facebook.source_files = 'FacebookAuth/FirebaseFacebookAuthUI/*.{h,m}'
    facebook.dependency 'FirebaseUI/Auth'
    facebook.dependency 'FBSDKLoginKit', '~> 4.35'
    facebook.resource_bundle = {
      'FirebaseFacebookAuthUI' => ['FacebookAuth/FirebaseFacebookAuthUI/**/*.{png,lproj}']
    }
    facebook.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/FirebaseUI/FirebaseFacebookAuthUI' }
  end

  s.subspec 'Google' do |google|
    google.platform = :ios, '8.0'
    google.public_header_files = 'GoogleAuth/FirebaseGoogleAuthUI/*.h'
    google.source_files = 'GoogleAuth/FirebaseGoogleAuthUI/*.{h,m}'
    google.dependency 'FirebaseUI/Auth'
    google.dependency 'GoogleSignIn', '~> 4.0'
    google.resource_bundle = {
      'FirebaseGoogleAuthUI' => ['GoogleAuth/FirebaseGoogleAuthUI/**/*.{png,lproj}']
    }
    google.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/FirebaseUI/FirebaseGoogleAuthUI' }
  end

  s.subspec 'OAuth' do |oauth|
    oauth.platform = :ios, '8.0'
    oauth.public_header_files = 'OAuth/FirebaseOAuthUI/*.h'
    oauth.source_files = 'OAuth/FirebaseOAuthUI/*.{h,m}'
    oauth.dependency 'FirebaseUI/Auth'
    oauth.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/FirebaseUI/FirebaseOAuthUI' }
  end

  s.subspec 'Phone' do |phone|
    phone.platform = :ios, '8.0'
    phone.public_header_files = ['PhoneAuth/FirebasePhoneAuthUI/FirebasePhoneAuthUI.h',
                                 'PhoneAuth/FirebasePhoneAuthUI/FUIPhoneAuth.h']
    phone.source_files = 'PhoneAuth/FirebasePhoneAuthUI/**/*.{h,m}'
    phone.dependency 'FirebaseUI/Auth'
    phone.resource_bundle = {
      'FirebasePhoneAuthUI' => ['PhoneAuth/FirebasePhoneAuthUI/*.xib',
                                'PhoneAuth/FirebasePhoneAuthUI/**/*.{xib,json,lproj,png}']
    }
    phone.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/FirebaseUI/FirebasePhoneAuthUI' }
  end

  s.subspec 'Twitter' do |twitter|
    twitter.public_header_files = 'TwitterAuth/FirebaseTwitterAuthUI/*.h'
    twitter.source_files = 'TwitterAuth/FirebaseTwitterAuthUI/*.{h,m}'
    twitter.dependency 'FirebaseUI/Auth'
    twitter.dependency 'TwitterKit', '~> 3.0'
    twitter.platform = :ios, '9.0'
    twitter.resource_bundle = {
      'FirebaseTwitterAuthUI' => ['TwitterAuth/FirebaseTwitterAuthUI/**/*.{png,lproj}']
    }
    twitter.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/FirebaseUI/FirebaseTwitterAuthUI' }
  end
end
