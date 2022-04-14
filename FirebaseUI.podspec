Pod::Spec.new do |s|
  s.name         = 'FirebaseUI'
  s.version      = '12.2.0'
  s.summary      = 'UI binding libraries for Firebase.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.source       = { :git => 'https://github.com/firebase/FirebaseUI-iOS.git', :tag => 'v' + s.version.to_s}
  s.author       = 'Firebase'
  s.platform = :ios
  s.ios.deployment_target = '10.0'
  s.ios.framework = 'UIKit'
  s.requires_arc = true
  s.public_header_files = 'FirebaseUI.h'
  s.source_files = 'FirebaseUI.h'
  s.swift_versions = '5.3'
  s.cocoapods_version = '>= 1.8.0'
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}"',
  }

  s.subspec 'Database' do |database|
    database.dependency 'FirebaseDatabaseUI', '~> 12.0'
  end

  s.subspec 'Firestore' do |firestore|
    firestore.dependency 'FirebaseFirestoreUI', '~> 12.0'
  end

  s.subspec 'Storage' do |storage|
    storage.dependency 'FirebaseStorageUI', '~> 12.0'
  end

  s.subspec 'Auth' do |auth|
    auth.dependency 'FirebaseAuthUI', '~> 12.0'
  end

  s.subspec 'Anonymous' do |anonymous|
    anonymous.dependency 'FirebaseAnonymousAuthUI', '~> 12.0'
  end

  s.subspec 'Email' do |email|
    email.dependency 'FirebaseEmailAuthUI', '~> 12.0'
  end

  s.subspec 'Facebook' do |facebook|
    facebook.dependency 'FirebaseFacebookAuthUI', '~> 12.0'
  end

  s.subspec 'Google' do |google|
    google.dependency 'FirebaseGoogleAuthUI', '~> 12.0'
  end

  s.subspec 'OAuth' do |oauth|
    oauth.dependency 'FirebaseOAuthUI', '~> 12.0'
  end

  s.subspec 'Phone' do |phone|
    phone.dependency 'FirebasePhoneAuthUI', '~> 12.0'
  end

end
