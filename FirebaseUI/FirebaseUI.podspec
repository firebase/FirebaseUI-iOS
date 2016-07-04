Pod::Spec.new do |s|
  s.name         = 'FirebaseUI'
  s.version      = '0.4.0'
  s.summary      = 'UI binding libraries for Firebase.'
  s.homepage     = 'https://github.com/firebase/FirebaseUI-iOS'
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author       = 'Firebase'
  s.source       = { :git => 'https://github.com/firebase/FirebaseUI-iOS.git', :tag => s.version }
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
    database.source_files = 'Database/**/*.{h,m}'
    database.dependency 'Firebase/Database', '~> 3.0'
  end

  s.subspec 'Auth' do |auth|
    auth.dependency 'FirebaseUI/AuthBase'
    auth.dependency 'FirebaseUI/Facebook'
    auth.dependency 'FirebaseUI/Google'
  end

  s.subspec 'AuthBase' do |authbase|
    authbase.source_files = 'Auth/AuthUI/Source/*.{h,m}'
    authbase.resource_bundles = {'FirebaseAuthUIBundle' => ['Auth/AuthUI/Resources/*.png', 'Auth/AuthUI/Strings/**/*.strings', 'Auth/AuthUI/Source/*.xib']}
    authbase.dependency 'Firebase/Analytics', '~> 3.0'
    authbase.dependency 'Firebase/Auth', '~> 3.0'
  end

  s.subspec 'Facebook' do |facebook|
    facebook.source_files = 'Auth/AuthProviderUI/Facebook/Source/*.{h,m}'
    facebook.resource_bundles = {'FirebaseFacebookAuthUIBundle' => ['Auth/AuthProviderUI/Facebook/Resources/*.png', 'Auth/AuthProviderUI/Facebook/Strings/**/*.strings'] }
    facebook.dependency 'FirebaseUI/AuthBase'
    facebook.dependency 'FBSDKLoginKit', '~> 4.0'
  end

  s.subspec 'Google' do |google|
    google.source_files = 'Auth/AuthProviderUI/Google/Source/*.{h,m}'
    google.resource_bundles = {'FirebaseGoogleAuthUIBundle' => ['Auth/AuthProviderUI/Google/Resources/*.png', 'Auth/AuthProviderUI/Google/Strings/**/*.strings'] }
    google.dependency 'FirebaseUI/AuthBase'
    google.dependency 'GoogleSignIn', '~> 4.0'
  end

end
