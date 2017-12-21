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
    pod 'OCMock'
  end
end

target 'FirebaseFacebookAuthUI' do
  use_frameworks!
  # Pods for Facebook Auth
  pod 'FBSDKLoginKit', '~> 4.0'
  pod 'FBSDKCoreKit', '~> 4.0'

  target 'FirebaseFacebookAuthUITests' do
    inherit! :search_paths
    pod 'OCMock'
    pod 'FBSDKLoginKit', '~> 4.0'
    pod 'FBSDKCoreKit', '~> 4.0'
  end
end

target 'FirebaseGoogleAuthUI' do
  use_frameworks!
  # Pods for Google Auth
  pod 'GoogleSignIn', '~> 4.0'

  target 'FirebaseGoogleAuthUITests' do
    inherit! :search_paths
    pod 'OCMock'
  end
end

target 'FirebasePhoneAuthUI' do
  use_frameworks!

  target 'FirebasePhoneAuthUITests' do
    inherit! :search_paths
    pod 'OCMock'
  end
end

target 'FirebaseTwitterAuthUI' do
  platform :ios, '9.0'
  use_frameworks!
  # Pods for Twitter Auth
  pod 'TwitterKit', '~> 3.0'

  target 'FirebaseTwitterAuthUITests' do
    platform :ios, '9.0'
    inherit! :search_paths
    pod 'OCMock'
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

target 'Database' do
  use_frameworks!
  # Pods for Database
  pod 'Firebase/Database'
end

target 'Storage' do
  use_frameworks!

  pod 'Firebase/Storage'
  pod 'SDWebImage', '~> 4.0'
end

target 'Auth' do
  use_frameworks!

  # Pods for Auth
  pod 'FirebaseAuth'
end

target 'Facebook' do
  use_frameworks!

  # Pods for Facebook Auth
  pod 'FirebaseAuth'
  pod 'FBSDKLoginKit', '~> 4.0'
end

target 'Google' do
  use_frameworks!

  # Pods for Google Auth
  pod 'FirebaseAuth'
  pod 'GoogleSignIn', '~> 4.0'
end

target 'Phone' do
  use_frameworks!

  # Pods for Phone Auth
  pod 'FirebaseAuth'
end

target 'Twitter' do
  platform :ios, '9.0'
  use_frameworks!

  # Pods for Twitter Auth
  pod 'FirebaseAuth'
  pod 'TwitterCore', '~> 3.0'
  pod 'TwitterKit', '~> 3.0'
end

target 'Firestore' do
  platform :ios, '9.0'
  use_frameworks!

  pod 'Firebase/Firestore'
end

target 'FirebaseUISample' do
  platform :ios, '9.0'

  pod 'OCMock'

  pod 'FirebaseAuthUI', :path => "FirebaseUI_dev_auth.podspec"
  pod 'FirebaseDatabaseUI', :path => "FirebaseUI_dev_db.podspec"
  pod 'FirebaseStorageUI', :path => "FirebaseUI_dev_storage.podspec"
  pod 'FirebaseFacebookAuthUI', :path => "FirebaseUI_dev_fb.podspec"
  pod 'FirebaseGoogleAuthUI', :path => "FirebaseUI_dev_ggl.podspec"
  pod 'FirebasePhoneAuthUI', :path => "FirebaseUI_dev_phone.podspec"
  pod 'FirebaseTwitterAuthUI', :path => "FirebaseUI_dev_tw.podspec"

  target 'FirebaseUISampleUITests' do
    inherit! :search_paths
  end

end
