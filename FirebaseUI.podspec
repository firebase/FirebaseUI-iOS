Pod::Spec.new do |s|
  s.name         = 'FirebaseUI'
  s.version      = '10.0.2'
  s.summary      = 'UI binding libraries for Firebase.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.source       = { :git => 'https://github.com/firebase/FirebaseUI-iOS.git', :tag => 'v' + s.version.to_s}
  s.author       = 'Firebase'
  s.platform = :ios
  s.ios.deployment_target = '10.0'
  s.static_framework = true
  s.ios.framework = 'UIKit'
  s.requires_arc = true
  s.public_header_files = 'FirebaseUI.h'
  s.source_files = 'FirebaseUI.h'
  s.cocoapods_version = '>= 1.8.0'
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}"',
  }

  s.subspec 'Database' do |database|
    database.platform = :ios, '10.0'
    database.public_header_files = 'FirebaseDatabaseUI/Sources/Public/*.h'
    database.source_files = 'FirebaseDatabaseUI/Sources/**/*.{h,m}'
    database.dependency 'Firebase/Database'
  end

  s.subspec 'Firestore' do |firestore|
    firestore.platform = :ios, '10.0'
    firestore.public_header_files = 'FirebaseFirestoreUI/Sources/Public/*.h'
    firestore.source_files = 'FirebaseFirestoreUI/Sources/**/*.{h,m}'
    firestore.dependency 'Firebase/Firestore'
  end

  s.subspec 'Storage' do |storage|
    storage.ios.deployment_target = '10.0'
    # storage.tvos.deployment_target = '11.0' Disabled; one of the dependencies doesn't support tvOS.
    storage.public_header_files = 'FirebaseStorageUI/Sources/Public/*.h'
    storage.source_files = 'FirebaseStorageUI/Sources/**/*.{h,m}'
    storage.dependency 'Firebase/Storage'
    storage.dependency 'SDWebImage', '~> 5.6'
  end

  s.subspec 'Auth' do |auth|
    auth.platform = :ios, '10.0'
    auth.public_header_files = 'FirebaseAuthUI/Sources/Public/*.h'
    auth.source_files = 'FirebaseAuthUI/Sources/**/*.{h,m}'
    auth.dependency 'Firebase/Auth', '>= 7.2.0'
    auth.dependency 'GoogleUtilities/UserDefaults'
    auth.resource_bundle = {
      'FirebaseAuthUI' => ['FirebaseAuthUI/Sources/{Resources,Strings}/*.{xib,png,lproj}']
    }
  end

  s.subspec 'Anonymous' do |anonymous|
    anonymous.platform = :ios, '10.0'
    anonymous.public_header_files = 'FirebaseAnonymousAuthUI/Sources/Public/*.h'
    anonymous.source_files = 'FirebaseAnonymousAuthUI/Sources/**/*.{h,m}'
    anonymous.dependency 'FirebaseUI/Auth'
    anonymous.resource_bundle = {
      'FirebaseAnonymousAuthUI' => [
        'FirebaseAnonymousAuthUI/Sources/{Resources,Strings}/*.{png,lproj}'
      ]
    }
  end

  s.subspec 'Email' do |email|
    email.platform = :ios, '10.0'
    email.public_header_files = 'FirebaseEmailAuthUI/Sources/Public/*.h'
    email.source_files = 'FirebaseEmailAuthUI/Sources/**/*.{h,m}'
    email.dependency 'FirebaseUI/Auth'
    email.resource_bundle = {
      'FirebaseEmailAuthUI' => ['FirebaseEmailAuthUI/Sources/Resources/*.{xib,png}']
    }
  end


  s.subspec 'Facebook' do |facebook|
    facebook.platform = :ios, '10.0'
    facebook.public_header_files = 'FirebaseFacebookAuthUI/Sources/Public/*.h'
    facebook.source_files = 'FirebaseFacebookAuthUI/Sources/**/*.{h,m}'
    facebook.dependency 'FirebaseUI/Auth'
    facebook.dependency 'FBSDKLoginKit', '~> 9.0'
    facebook.resource_bundle = {
      'FirebaseFacebookAuthUI' => ['FirebaseFacebookAuthUI/Sources/{Resources,Strings}/*.{png,lproj}']
    }
  end

  s.subspec 'Google' do |google|
    google.platform = :ios, '10.0'
    google.public_header_files = 'FirebaseGoogleAuthUI/Sources/Public/*.h'
    google.source_files = 'FirebaseGoogleAuthUI/Sources/**/*.{h,m}'
    google.dependency 'FirebaseUI/Auth'
    google.dependency 'GoogleSignIn', '~> 5.0'
    google.resource_bundle = {
      'FirebaseGoogleAuthUI' => ['FirebaseGoogleAuthUI/Sources/{Resources,Strings}/*.{png,lproj}']
    }
  end

  s.subspec 'OAuth' do |oauth|
    oauth.platform = :ios, '10.0'
    oauth.public_header_files = 'FirebaseOAuthUI/Sources/Public/*.h'
    oauth.source_files = 'FirebaseOAuthUI/Sources/**/*.{h,m}'
    oauth.dependency 'FirebaseUI/Auth'
    oauth.resource_bundle = {
      'FirebaseOAuthUI' => ['FirebaseOAuthUI/Sources/{Resources,Strings}/*.{png,lproj}']
    }
  end

  s.subspec 'Phone' do |phone|
    phone.platform = :ios, '10.0'
    phone.public_header_files = 'FirebasePhoneAuthUI/Sources/Public/*.h'
    phone.source_files = 'FirebasePhoneAuthUI/Sources/**/*.{h,m}'
    phone.dependency 'FirebaseUI/Auth'
    phone.resource_bundle = {
      'FirebasePhoneAuthUI' => ['FirebasePhoneAuthUI/Sources/{Resources,Strings}/*.{xib,json,lproj,png}']
    }
  end

end
