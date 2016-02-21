Pod::Spec.new do |s|
  s.name         = "FirebaseUI"
  s.version      = "0.3.2"
  s.summary      = "UI binding libraries for Firebase."
  s.homepage     = "https://github.com/firebase/FirebaseUI-iOS"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Firebase" => "support@firebase.com" }
  s.social_media_url = "https://twitter.com/firebase"
  s.source       = { :git => "https://github.com/firebase/FirebaseUI-iOS.git", :tag => 'v0.3.2' }
  s.platform = :ios
  s.ios.deployment_target = "8.0"
  s.dependency "Firebase", "~>2.2"
  s.ios.framework = "UIKit"
  s.xcconfig     = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/Firebase"' }
  s.requires_arc = true
  s.default_subspecs = 'Core', 'Auth'

  s.subspec 'Core' do |core|
    core.source_files = "FirebaseUI/{Core,Util}/**/*.{h,m}"
  end

  s.subspec 'Auth' do |auth|
    auth.dependency "FirebaseUI/Facebook"
    auth.dependency "FirebaseUI/Google"
    auth.dependency "FirebaseUI/Twitter"
    auth.dependency "FirebaseUI/Password"
  end

  s.subspec 'AuthHelper' do |helper|
    helper.source_files = "FirebaseUI/Auth/**/{FirebaseAppDelegate,FirebaseLoginViewController,FirebaseAuthConstants,FirebaseAuthDelegate,FirebaseAuthProvider,FirebaseLoginButton}.{h,m}"
    helper.resources = "FirebaseUI/Auth/Resources/*"
  end

  s.subspec 'Facebook' do |facebook|
    facebook.source_files = "FirebaseUI/Auth/**/FirebaseFacebookAuthProvider.{h,m}"
    facebook.dependency "FirebaseUI/AuthHelper"
    facebook.dependency "FBSDKCoreKit"
    facebook.dependency "FBSDKLoginKit"
    facebook.xcconfig = {"OTHER_CFLAGS" => "-DFIREBASEUI_ENABLE_FACEBOOK_AUTH=1"}
  end

  s.subspec 'Google' do |google|
    google.source_files = "FirebaseUI/Auth/**/FirebaseGoogleAuthProvider.{h,m}"
    google.dependency "FirebaseUI/AuthHelper"
    google.dependency "Google/SignIn"
    google.xcconfig = {"OTHER_CFLAGS" => "-DFIREBASEUI_ENABLE_GOOGLE_AUTH=1 -DLOCAL_BUILD=0"}
  end

  s.subspec 'Twitter' do |twitter|
    twitter.source_files = "FirebaseUI/Auth/**/{FirebaseTwitterAuthProvider,TwitterAuthDelegate}.{h,m}"
    twitter.dependency "FirebaseUI/AuthHelper"
    twitter.ios.framework = "Accounts"
    twitter.xcconfig = {"OTHER_CFLAGS" => "-DFIREBASEUI_ENABLE_TWITTER_AUTH=1"}
  end

  s.subspec 'Password' do |password|
    password.source_files = "FirebaseUI/Auth/**/FirebasePasswordAuthProvider.{h,m}"
    password.dependency "FirebaseUI/AuthHelper"
    password.xcconfig = {"OTHER_CFLAGS" => "-DFIREBASEUI_ENABLE_PASSWORD_AUTH=1"}
  end
end
