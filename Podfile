# Uncomment this line to define a global platform for your project
platform :ios, '8.0'

target 'FirebaseDatabaseUI' do
  use_frameworks!

  # Pods for Database
  pod 'Firebase/Database'

  target 'FirebaseDatabaseUITests' do
    inherit! :search_paths
  end
end

target 'FirebaseStorageUI' do
  use_frameworks!

  pod 'Firebase/Storage'
  pod 'SDWebImage', '~> 4.0'

  target 'FirebaseStorageUITests' do
    inherit! :search_paths
    pod 'SDWebImage', '~> 4.0'
    pod 'OCMock'
  end
end

target 'FirebaseAuthUI' do
  use_frameworks!

  # Pods for Auth
  pod 'FirebaseAuth'

  target 'FirebaseAuthUITests' do
    inherit! :search_paths
  end

  target 'FirebaseAnonymousAuthUI' do
    inherit! :search_paths

    target 'FirebaseAnonymousAuthUITests' do
      inherit! :search_paths
      pod 'OCMock'
    end
  end

  target 'FirebaseFacebookAuthUI' do
    inherit! :search_paths
    # Pods for Facebook Auth
    # These are pinned to 4.35.0 to work around this bug:
    # https://developers.facebook.com/support/bugs/242258916492125/?disable_redirect=0
    pod 'FBSDKLoginKit', '= 4.35.0'
    pod 'FBSDKCoreKit', '= 4.35.0'

    target 'FirebaseFacebookAuthUITests' do
      inherit! :search_paths
      pod 'OCMock'
    end
  end

  target 'FirebaseGoogleAuthUI' do
    inherit! :search_paths
    # Pods for Google Auth
    pod 'GoogleSignIn', '~> 4.0'

    target 'FirebaseGoogleAuthUITests' do
      inherit! :search_paths
      pod 'OCMock'
    end
  end

  target 'FirebasePhoneAuthUI' do
    inherit! :search_paths

    target 'FirebasePhoneAuthUITests' do
      inherit! :search_paths
      pod 'OCMock'
    end
  end

  target 'FirebaseTwitterAuthUI' do
    platform :ios, '9.0'
    inherit! :search_paths
    # Pods for Twitter Auth
    pod 'TwitterKit', '~> 3.0'

    target 'FirebaseTwitterAuthUITests' do
      platform :ios, '9.0'
      inherit! :search_paths
      pod 'OCMock'
    end
  end
end

target 'FirebaseFirestoreUI' do
  use_frameworks!

  # Pods for Firestore
  pod 'Firebase/Firestore'

  target 'FirebaseFirestoreUITests' do
    inherit! :search_paths
  end
end

target 'FirebaseUISample' do
  use_frameworks!
  platform :ios, '9.0'

  pod 'OCMock'
  # pod 'FirebaseUI/Anonymous', :path => '.'
  # pod 'FirebaseUI/Auth', :path => '.'
  # pod 'FirebaseUI/Facebook', :path => '.'
  # pod 'FirebaseUI/Google', :path => '.'
  # pod 'FirebaseUI/Twitter', :path => '.'
  # pod 'FirebaseUI/Phone', :path => '.'

  target 'FirebaseUISampleUITests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
  end
end
